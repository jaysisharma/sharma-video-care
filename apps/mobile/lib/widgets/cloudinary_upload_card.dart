import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/cloudinary_service.dart';
import '../theme_tokens.dart';

/// Reusable UI widget for uploading images to Cloudinary with
/// camera/gallery picker, live upload indicator, and thumbnail preview.
class CloudinaryUploadCard extends StatefulWidget {
  final String? imageUrl;
  final String label;
  final String? helperText;
  final IconData icon;
  final String folder;
  final ValueChanged<String>? onUploaded;
  final VoidCallback? onRemoved;
  final double height;

  const CloudinaryUploadCard({
    super.key,
    this.imageUrl,
    required this.label,
    this.helperText,
    this.icon = Icons.camera_alt_outlined,
    this.folder = 'video_care',
    this.onUploaded,
    this.onRemoved,
    this.height = 110,
  });

  @override
  State<CloudinaryUploadCard> createState() => _CloudinaryUploadCardState();
}

class _CloudinaryUploadCardState extends State<CloudinaryUploadCard> {
  bool _isUploading = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(covariant CloudinaryUploadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      setState(() {
        _currentUrl = widget.imageUrl;
      });
    }
  }

  Future<void> _startUpload() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);
    try {
      final url = await CloudinaryService().showImagePickerModal(
        context,
        folder: widget.folder,
        title: 'Upload ${widget.label}',
      );

      if (url != null && mounted) {
        setState(() {
          _currentUrl = url;
        });
        widget.onUploaded?.call(url);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _currentUrl = null;
    });
    widget.onRemoved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _currentUrl != null && _currentUrl!.isNotEmpty;

    if (_isUploading) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: SvcColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SvcColors.primary, width: 1.5),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(SvcColors.primary),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Uploading to Cloudinary...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SvcColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasImage) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageUrl: CloudinaryService().getOptimizedUrl(
                      _currentUrl!,
                      width: 200,
                      height: 200,
                    ),
                    width: widget.height,
                    height: widget.height,
                    fit: BoxFit.cover,
                    placeholder: (context, _) => Container(
                      width: widget.height,
                      height: widget.height,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, _, __) => Container(
                      width: widget.height,
                      height: widget.height,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Color(0xFF059669)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF065F46),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Cloudinary CDN Verified',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF047857),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _startUpload,
                          child: const Text(
                            'Replace Photo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: SvcColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 6,
              right: 6,
              child: InkWell(
                onTap: _removePhoto,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _startUpload,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: SvcColors.canvas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SvcColors.border, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SvcColors.border),
              ),
              child: Icon(widget.icon, color: SvcColors.muted, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SvcColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.helperText ?? 'Tap to snap photo or select from gallery',
                    style: const TextStyle(
                      fontSize: 11,
                      color: SvcColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_photo_alternate_outlined, color: SvcColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
