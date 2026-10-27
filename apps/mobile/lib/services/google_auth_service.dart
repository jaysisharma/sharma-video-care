import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';

/// OAuth client ids for Google sign-in. Both are created when the Google provider
/// is enabled in Firebase Console › Authentication › Sign-in method.
/// - iOS: `CLIENT_ID` from the re-downloaded GoogleService-Info.plist (also add its
///   `REVERSED_CLIENT_ID` as a URL scheme in ios/Runner/Info.plist).
/// - Android: the "Web client" id (client_type 3) from google-services.json.
/// Running `flutterfire configure` fills [DefaultFirebaseOptions.ios.iosClientId] instead.
class GoogleAuthConfig {
  static const String? iosClientId = null;
  static const String? androidServerClientId = null;
}

class GoogleSignInNotConfigured implements Exception {
  const GoogleSignInNotConfigured();
}

/// Thrown when the user closes the Google account picker; not an error to show.
class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
}

class GoogleAuthService {
  GoogleAuthService._();

  static Future<void>? _initialization;

  static String? get _iosClientId => DefaultFirebaseOptions.ios.iosClientId ?? GoogleAuthConfig.iosClientId;

  /// False until the client ids above exist; the button explains instead of crashing
  /// (the iOS SDK aborts the app if started without a client id and URL scheme).
  static bool get isConfigured {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return _iosClientId != null;
      case TargetPlatform.android:
        return GoogleAuthConfig.androidServerClientId != null;
      default:
        return false;
    }
  }

  static Future<void> _ensureInitialized() {
    return _initialization ??= GoogleSignIn.instance.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS ? _iosClientId : null,
      serverClientId: defaultTargetPlatform == TargetPlatform.android ? GoogleAuthConfig.androidServerClientId : null,
    );
  }

  /// Shows the Google account picker and returns the ID token for Firebase.
  static Future<String> requestIdToken() async {
    if (!isConfigured) throw const GoogleSignInNotConfigured();
    await _ensureInitialized();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const GoogleSignInNotConfigured();
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled || e.code == GoogleSignInExceptionCode.interrupted) {
        throw const GoogleSignInCancelled();
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw const GoogleSignInNotConfigured();
      }
      rethrow;
    }
  }

  /// Clears the cached Google account so the picker shows again next time. The
  /// plugin is started first if needed (e.g. after an app restart).
  static Future<void> signOut() async {
    if (!isConfigured) return;
    try {
      await _ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Google sign-out note: $e');
    }
  }
}
