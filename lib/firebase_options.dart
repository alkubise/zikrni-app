import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web options are not configured.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS options are not configured.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'macOS options are not configured.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Windows options are not configured.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Linux options are not configured.',
        );
      default:
        throw UnsupportedError(
          'This platform is not supported.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PUT_YOUR_ANDROID_API_KEY_HERE',
    appId: 'PUT_YOUR_ANDROID_APP_ID_HERE',
    messagingSenderId: 'PUT_YOUR_MESSAGING_SENDER_ID_HERE',
    projectId: 'PUT_YOUR_PROJECT_ID_HERE',
    storageBucket: 'PUT_YOUR_STORAGE_BUCKET_HERE',
  );
}