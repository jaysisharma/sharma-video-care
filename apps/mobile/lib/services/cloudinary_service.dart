import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Cloudinary media service for QuickySewa mobile app.
/// Uploads are signed by the `signCloudinaryUpload` Cloud Function, so the API
/// secret never ships in the app. Also handles image picking and CDN transforms.
class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  static const String cloudName = 'esmfahf0';
  // The API key is public (it identifies the account); the secret stays on the server.
  static const String apiKey = '774116671947288';
  static const String uploadEndpoint =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  final ImagePicker _picker = ImagePicker();

  /// Asks the server to sign an upload into [folder]. Guests are signed in
  /// anonymously first because the function only signs for signed-in users.
  Future<({String folder, int timestamp, String signature})> _requestSignature(String folder) async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    final result = await FirebaseFunctions.instance
        .httpsCallable('signCloudinaryUpload')
        .call<Map<String, dynamic>>({'folder': folder});
    final data = Map<String, dynamic>.from(result.data);
    return (
      folder: data['folder'] as String,
      timestamp: (data['timestamp'] as num).toInt(),
      signature: data['signature'] as String,
    );
  }

  http.MultipartRequest _signedRequest(({String folder, int timestamp, String signature}) signed) {
    return http.MultipartRequest('POST', Uri.parse(uploadEndpoint))
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = signed.timestamp.toString()
      ..fields['folder'] = signed.folder
      ..fields['signature'] = signed.signature;
  }

  /// Upload raw image bytes directly using multipart/form-data.
  /// Returns the secure HTTPS Cloudinary URL on success, or null on failure.
  Future<String?> uploadImageBytes(
    Uint8List bytes, {
    String filename = 'photo.jpg',
    String folder = 'video_care',
  }) async {
    try {
      final request = _signedRequest(await _requestSignature(folder));
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['secure_url'] as String? ?? data['url'] as String?;
      } else {
        debugPrint('Cloudinary upload error (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('CloudinaryService uploadImageBytes exception: $e');
      return null;
    }
  }

  /// Upload a File from local device storage using multipart/form-data.
  Future<String?> uploadFile(
    File file, {
    String folder = 'video_care',
  }) async {
    if (!await file.exists()) {
      debugPrint('CloudinaryService: Local file does not exist: ${file.path}');
      return null;
    }
    final bytes = await file.readAsBytes();
    final filename = file.path.split(Platform.pathSeparator).last;
    return uploadImageBytes(bytes, filename: filename, folder: folder);
  }

  /// Upload an XFile (from image_picker or cross-platform storage).
  Future<String?> uploadXFile(
    XFile xFile, {
    String folder = 'video_care',
  }) async {
    try {
      final bytes = await xFile.readAsBytes();
      final filename = xFile.name.isNotEmpty ? xFile.name : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await uploadImageBytes(bytes, filename: filename, folder: folder);
    } catch (e) {
      debugPrint('CloudinaryService uploadXFile exception: $e');
      return null;
    }
  }

  /// Upload a base64 Data URI or raw base64 string.
  Future<String?> uploadBase64(
    String base64Data, {
    String folder = 'video_care',
  }) async {
    try {
      final request = _signedRequest(await _requestSignature(folder))..fields['file'] = base64Data;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['secure_url'] as String? ?? data['url'] as String?;
      } else {
        debugPrint('Cloudinary upload error (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('CloudinaryService uploadBase64 exception: $e');
      return null;
    }
  }

  /// Pick an image from [source] (Camera or Gallery) and immediately upload to Cloudinary.
  /// Returns the uploaded image URL, or null if cancelled or upload failed.
  Future<String?> pickAndUploadImage({
    ImageSource source = ImageSource.gallery,
    String folder = 'video_care',
    double? maxWidth = 1920,
    double? maxHeight = 1920,
    int? imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;
      return await uploadXFile(pickedFile, folder: folder);
    } catch (e) {
      debugPrint('CloudinaryService pickAndUploadImage error: $e');
      return null;
    }
  }

  /// Shows a modal bottom sheet allowing user to choose between Camera or Photo Gallery,
  /// then picks and uploads the image to Cloudinary.
  Future<String?> showImagePickerModal(
    BuildContext context, {
    String folder = 'video_care',
    String title = 'Upload Photo',
  }) async {
    final ImageSource? selectedSource = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFFE86F1C)),
                  title: const Text('Take Photo with Camera'),
                  subtitle: const Text('Snap an instant photo of your gear or defect'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF2563EB)),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Select existing photos from device gallery'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (selectedSource == null) return null;

    return pickAndUploadImage(
      source: selectedSource,
      folder: folder,
    );
  }

  /// Generates a transformed, responsive Cloudinary URL (auto-format, auto-quality, resizing).
  String getOptimizedUrl(
    String url, {
    int? width,
    int? height,
    String quality = 'auto',
    String crop = 'limit',
  }) {
    if (!url.contains('res.cloudinary.com')) {
      return url;
    }

    final transforms = <String>['f_auto', 'q_$quality'];
    if (width != null) transforms.add('w_$width');
    if (height != null) transforms.add('h_$height');
    if (width != null || height != null) transforms.add('c_$crop');

    final transformString = transforms.join(',');
    const uploadMarker = '/upload/';
    final uploadIndex = url.indexOf(uploadMarker);
    if (uploadIndex == -1) return url;

    return '${url.substring(0, uploadIndex + uploadMarker.length)}$transformString/${url.substring(uploadIndex + uploadMarker.length)}';
  }
}
