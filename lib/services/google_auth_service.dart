import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns Firebase [User] if success, otherwise null (cancelled)
  static Future<User?> signInWithGoogle() async {
    // ✅ WEB: popup + force account chooser
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});

      final cred = await _auth.signInWithPopup(provider);
      return cred.user;
    }

    // ✅ ANDROID/iOS: account chooser
    final googleSignIn = GoogleSignIn(
      scopes: const ['email'],
    );

    // ✅ Force chooser every time (optional but useful)
    // If you don't want to force chooser, remove this line.
    await googleSignIn.signOut();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // cancelled

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    return userCred.user;
  }

  static Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
    await _auth.signOut();
  }
}
