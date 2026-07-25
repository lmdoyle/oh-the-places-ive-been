import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  // Passed explicitly (rather than via the index.html meta tag) so the web
  // client ID doesn't sit in plaintext in the public GitHub repo — supplied
  // at build time via --dart-define-from-file. Only relevant on web; native
  // Google Sign-In uses the SHA fingerprint registered against
  // google-services.json instead, so this is left unset elsewhere.
  static final _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? const String.fromEnvironment('GOOGLE_SIGNIN_CLIENT_ID')
        : null,
  );

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get userStream => _auth.authStateChanges();

  static Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  static Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  static Future<User?> registerWithEmail(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
