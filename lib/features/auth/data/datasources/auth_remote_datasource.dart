import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> signInWithEmail(String email, String password);
  Future<AuthModel> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  );
  Future<AuthModel?> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<User?> get authStateChanges;
}
