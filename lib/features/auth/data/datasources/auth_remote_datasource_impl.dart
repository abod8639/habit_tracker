import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/generated/l10n.dart'; // لاستخدام الترجمة في الأخطاء
import '../models/auth_model.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       // استخدام .instance كما في الكود الذي يعمل لديك
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<AuthModel?> signInWithGoogle() async {
    try {
      // 1. التهيئة (كما في الكود الناجح لديك)
      await _googleSignIn.initialize(
        serverClientId:
            '575224289908-h8s7sbtfj2bm6f0hiddld65cvauehk93.apps.googleusercontent.com',
      );

      // 2. بدء عملية المصادقة باستخدام authenticate() بدلاً من signIn()
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // 3. الحصول على تفاصيل التوثيق
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 4. إنشاء الكريدنشال (لاحظ استخدام idToken فقط كما في كودك)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 5. تسجيل الدخول في فيربيز
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

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
    } catch (e) {
      throw AuthException('${S.current.authErrorGoogle}: $e');
    }
  }

  @override
  Future<AuthModel> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthModel.fromFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e));
    }
  }

  @override
  Future<AuthModel> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.isNotEmpty) {
        await result.user?.updateDisplayName(displayName);
        await result.user?.reload();
      }

      final user = _auth.currentUser;
      return AuthModel.fromFirebaseUser(user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('${S.current.authErrorSignOut}: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e));
    }
  }

  // دالة معالجة الأخطاء لتوحيد الرسائل بناءً على ملفات الترجمة لديك
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return S.current.authErrorUserNotFound;
      case 'wrong-password':
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
        return '${S.current.authErrorDefault}: ${e.message ?? e.code}';
    }
  }
}
