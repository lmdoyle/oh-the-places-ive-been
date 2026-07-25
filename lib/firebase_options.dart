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

  // Supplied at build time via --dart-define-from-file so the web project's
  // Firebase config doesn't sit in plaintext in the public GitHub repo. See
  // web_secrets.example.json for the expected keys.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByQn24pcEWWCLfLSfmUo6-tPhom4tDCgo',
    appId: '1:525029509867:android:5ed5bd12066fc8be0b4cae',
    messagingSenderId: '525029509867',
    projectId: 'oh-the-places-ive-been',
    storageBucket: 'oh-the-places-ive-been.firebasestorage.app',
  );
}
