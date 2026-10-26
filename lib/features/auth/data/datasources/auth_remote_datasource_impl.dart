import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../models/auth_model.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  static const Duration authTimeout = Duration(seconds: 25);

  AuthRemoteDataSourceImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<AuthModel?> signInWithGoogle() async {
    try {
      await _googleSignIn
          .initialize(
            serverClientId:
                '575224289908-h8s7sbtfj2bm6f0hiddld65cvauehk93.apps.googleusercontent.com',
          )
          .timeout(authTimeout);

      final GoogleSignInAccount googleUser = await _googleSignIn
          .authenticate()
          .timeout(authTimeout);

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth
          .signInWithCredential(credential)
          .timeout(authTimeout);

      if (result.user == null) return null;

      return AuthModel.fromFirebaseUser(result.user!);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw AuthException(
        '${S.current.authErrorGoogle}: ${e.description ?? e.code}',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e));
    } on TimeoutException {
      throw const TimeoutAppException(
        'Google authentication timed out. Please check your network.',
      );
    } catch (e) {
      if (e is AuthException || e is TimeoutAppException) rethrow;
      throw AuthException('${S.current.authErrorGoogle}: $e');
    }
  }

  @override
  Future<AuthModel> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(authTimeout);

      if (result.user == null) {
        throw const AuthException(
          'Failed to retrieve authenticated user profile',
        );
      }

      return AuthModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e));
    } on TimeoutException {
      throw const TimeoutAppException(
        'Sign in timed out. Please check your network connection.',
      );
    }
  }

  @override
  Future<AuthModel> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final UserCredential result = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(authTimeout);

      if (result.user == null) {
        throw const AuthException('Failed to create user account');
      }

      if (displayName != null && displayName.isNotEmpty) {
        await result.user?.updateDisplayName(displayName).timeout(authTimeout);
        await result.user?.reload().timeout(authTimeout);
      }

      final user = _auth.currentUser ?? result.user;
      if (user == null) {
        throw const AuthException(
          'User account created but profile is unavailable',
        );
      }

      return AuthModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e));
    } on TimeoutException {
      throw const TimeoutAppException(
        'Sign up timed out. Please check your network connection.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]).timeout(authTimeout);
    } on TimeoutException {
      throw const TimeoutAppException('Sign out timed out. Please try again.');
    } catch (e) {
      throw AuthException('${S.current.authErrorSignOut}: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth
          .sendPasswordResetEmail(email: email.trim())
          .timeout(authTimeout);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e));
    } on TimeoutException {
      throw const TimeoutAppException(
        'Password reset timed out. Please check your network.',
      );
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return S.current.authErrorUserNotFound;
      case 'wrong-password':
      case 'invalid-credential':
        return S.current.authErrorWrongPassword;
      case 'email-already-in-use':
        return S.current.authErrorEmailInUse;
      case 'invalid-email':
        return S.current.authErrorInvalidEmail;
      case 'weak-password':
        return S.current.authErrorWeakPassword;
      case 'too-many-requests':
        return S.current.authErrorTooManyRequests;
      case 'network-request-failed':
        return S.current.authErrorNetworkFailed;
      default:
        return e.message ?? S.current.authErrorDefault;
    }
  }
}
