// Generated file; do not edit.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCRUfN2jocpF03oED8YGOnKwrmCFQ5gRIk',
    authDomain: 'safecare-e6624.firebaseapp.com',
    projectId: 'safecare-e6624',
    storageBucket: 'safecare-e6624.firebasestorage.app',
    messagingSenderId: '358846030302',
    appId: '1:358846030302:web:a108b80e3a5d98454bfd4f',
    measurementId: 'G-DWZJZVHTJZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_ANDROID_API_KEY',
    appId: '1:358846030302:android:d656a14398913cee4bfd4f',
    messagingSenderId: '358846030302',
    projectId: 'safecare-e6624',
    storageBucket: 'safecare-e6624.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: '1:358846030302:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '358846030302',
    projectId: 'safecare-e6624',
    storageBucket: 'safecare-e6624.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_MACOS_API_KEY',
    appId: '1:358846030302:macos:REPLACE_WITH_MACOS_APP_ID',
    messagingSenderId: '358846030302',
    projectId: 'safecare-e6624',
    storageBucket: 'safecare-e6624.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_WINDOWS_API_KEY',
    appId: '1:358846030302:windows:REPLACE_WITH_WINDOWS_APP_ID',
    messagingSenderId: '358846030302',
    projectId: 'safecare-e6624',
    storageBucket: 'safecare-e6624.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_WITH_LINUX_API_KEY',
    appId: '1:358846030302:linux:REPLACE_WITH_LINUX_APP_ID',
    messagingSenderId: '358846030302',
    projectId: 'safecare-e6624',
    storageBucket: 'safecare-e6624.firebasestorage.app',
  );
}