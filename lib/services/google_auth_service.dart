import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:smart_farm_sheba/services/email_service.dart';

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> _afterSignIn(User user, bool isNew) async {
    final email = user.email ?? '';
    final fullName = (user.displayName ?? '').trim();
    final name = fullName.isEmpty ? email.split('@').first : fullName;

    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snap = await ref.get().timeout(const Duration(seconds: 10));
      if (!snap.exists) {
        final parts = name.split(' ');
        final first = parts.first;
        final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        await ref.set({
          'uid': user.uid,
          'name': name,
          'firstName': first,
          'lastName': last,
          'phone': '',
          'email': email,
          'zila': '',
          'role': 'farmer',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      debugPrint('Google profile setup failed: $e');
    }

    if (email.isEmpty) return;

    if (isNew) {
      EmailService.sendWelcome(toEmail: email, toName: name);
    } else {
      EmailService.sendLoginAlert(toEmail: email, toName: name);
    }
  }

  static Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});

      final cred = await _auth.signInWithPopup(provider);
      final user = cred.user;
      if (user != null) {
        final isNew = cred.additionalUserInfo?.isNewUser ?? false;
        await _afterSignIn(user, isNew);
      }
      return user;
    }

    final googleSignIn = GoogleSignIn(
      scopes: const ['email'],
    );

    await googleSignIn.signOut();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user;
    if (user != null) {
      final isNew = userCred.additionalUserInfo?.isNewUser ?? false;
      await _afterSignIn(user, isNew);
    }
    return user;
  }

  static Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
    await _auth.signOut();
  }
}
