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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for web and android.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA5Dzl0YVwwmXZTJK7uFRUCIm8gNLS-g9w',
    appId: '1:525029509867:web:f2cba8464e55663c0b4cae',
    messagingSenderId: '525029509867',
    projectId: 'oh-the-places-ive-been',
    authDomain: 'oh-the-places-ive-been.firebaseapp.com',
    storageBucket: 'oh-the-places-ive-been.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByQn24pcEWWCLfLSfmUo6-tPhom4tDCgo',
    appId: '1:525029509867:android:5ed5bd12066fc8be0b4cae',
    messagingSenderId: '525029509867',
    projectId: 'oh-the-places-ive-been',
    storageBucket: 'oh-the-places-ive-been.firebasestorage.app',
  );
}
