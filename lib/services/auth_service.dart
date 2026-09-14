import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_profile_model.dart';

/// Interface for Authentication Service.
abstract class AuthService {
  Stream<UserProfileModel?> get authStateChanges;
  Future<UserProfileModel?> getCurrentUser();

  Future<UserProfileModel> signInWithEmail(
    String email,
    String password,
  );

  Future<UserProfileModel> registerWithEmail(
    String name,
    String email,
    String password,
  );

  Future<UserProfileModel> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

/// Firebase Authentication Service.
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  Stream<UserProfileModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_userToProfile);
  }

  @override
  Future<UserProfileModel?> getCurrentUser() async {
    return _userToProfile(_firebaseAuth.currentUser);
  }

  UserProfileModel? _userToProfile(User? user) {
    if (user == null) return null;

    return UserProfileModel(
      uid: user.uid,
      name: user.displayName ?? 'User',
      email: user.email ?? '',
      avatarUrl: user.photoURL ?? '',
    );
  }

  @override
  Future<UserProfileModel> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _userToProfile(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    }
  }

  @override
  Future<UserProfileModel> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      return _userToProfile(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    }
  }

  @override
  Future<UserProfileModel> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        final userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
        return _userToProfile(userCredential.user)!;
      }

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return _userToProfile(userCredential.user)!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseErrorMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Continue with Firebase sign out even if Google sign-out fails.
    }

    await _firebaseAuth.signOut();
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'popup-closed-by-user':
        return 'Google sign-in was cancelled.';
      case 'popup-blocked':
        return 'Google sign-in popup was blocked by the browser.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      case 'unauthorized-domain':
        return 'This domain is not authorized in Firebase.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
