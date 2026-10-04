// File generated for Sharma Video Care Firebase integration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCvU-6LtUec49iLhk2AwcIlrjup2-jwX-4',
    appId: '1:753503373289:web:5749dd73c9a70d76a82d78',
    messagingSenderId: '753503373289',
    projectId: 'video-care-456d3',
    authDomain: 'video-care-456d3.firebaseapp.com',
    storageBucket: 'video-care-456d3.firebasestorage.app',
    measurementId: 'G-NXT9BNZLB4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCd6ciGTHx4mhBsiHpOvtAVHpTXhjYVx3Y',
    appId: '1:753503373289:android:36d19c8f642ec882a82d78',
    messagingSenderId: '753503373289',
    projectId: 'video-care-456d3',
    storageBucket: 'video-care-456d3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAemoJMwqvVp9YkZ9rc-SeRAOP565SoOkM',
    appId: '1:753503373289:ios:b31aca5b2c2efa64a82d78',
    messagingSenderId: '753503373289',
    projectId: 'video-care-456d3',
    storageBucket: 'video-care-456d3.firebasestorage.app',
    iosBundleId: 'com.sharmavideocare.app',
  );
}
