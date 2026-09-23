import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/get_auth_state_usecase.dart';
import '../../domain/usecases/set_skip_login_usecase.dart';
import '../pages/login_page.dart';
import 'package:habit_tracker/core/services/fcm_service.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_local_data_source.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/sync_controller.dart';

class AuthController extends GetxController {
  // Use Cases
  final SignInWithEmailUseCase _signInWithEmailUseCase = Get.find();
  final SignUpWithEmailUseCase _signUpWithEmailUseCase = Get.find();
  final SignInWithGoogleUseCase _signInWithGoogleUseCase = Get.find();
  final SignOutUseCase _signOutUseCase = Get.find();
  final ResetPasswordUseCase _resetPasswordUseCase = Get.find();
  final GetAuthStateUseCase _getAuthStateUseCase = Get.find();
  final SetSkipLoginUseCase _setSkipLoginUseCase = Get.find();

  // Observable state
  final Rx<AuthEntity?> _currentUser = Rx<AuthEntity?>(null);
  AuthEntity? get currentUser => _currentUser.value;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _currentUser.bindStream(_getAuthStateUseCase());
    ever(_currentUser, (user) {
      if (user != null && Get.isRegistered<FcmService>()) {
        Get.find<FcmService>().syncTokenToFirestore();
      }
    });
  }

  // Sign in with email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _signInWithEmailUseCase(email, password);

      final isSuccess = result.fold<bool>(
        (failure) {
          isLoading.value = false;
          errorMessage.value = failure.message;
          _showError(failure.message);
          return false;
        },
        (user) {
          isLoading.value = false;
          return true;
        },
      );
      return isSuccess;
    } catch (e) {
      isLoading.value = false;
      _showError(e.toString());
      return false;
    }
  }

  // Sign up with email
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _signUpWithEmailUseCase(
        email,
        password,
        displayName,
      );

      final isSuccess = result.fold<bool>(
        (failure) {
          isLoading.value = false;
          errorMessage.value = failure.message;
          _showError(failure.message);
          return false;
        },
        (user) {
          isLoading.value = false;
          return true;
        },
      );
      return isSuccess;
    } catch (e) {
      isLoading.value = false;
      _showError(e.toString());
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _signInWithGoogleUseCase();

      final isSuccess = result.fold<bool>(
        (failure) {
          isLoading.value = false;
          errorMessage.value = failure.message;
          _showError(failure.message);
          return false;
        },
        (user) {
          isLoading.value = false;
          return user != null;
        },
      );
      return isSuccess;
    } catch (e) {
      isLoading.value = false;
      _showError(e.toString());
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      // Reset skip login status so they see login screen again
      await _setSkipLoginUseCase(false);

      // Clear FCM token in Firestore before signing out
      if (Get.isRegistered<FcmService>()) {
        await Get.find<FcmService>().clearTokenFromFirestore();
      }

      // Reset habit data to default state
      if (Get.isRegistered<HabitController>()) {
        await Get.find<HabitController>().resetToDefaultState();
      } else if (Get.isRegistered<HabitLocalDataSource>()) {
        await Get.find<HabitLocalDataSource>().clearAllData();
      }

      // Reset sync state
      if (Get.isRegistered<SyncController>()) {
        final syncController = Get.find<SyncController>();
        syncController.lastSyncTime.value = null;
        syncController.syncStatus.value = SyncStatus.idle;
      }

      final result = await _signOutUseCase();

      result.fold(
        (failure) => _showError(failure.message),
        (_) => null,
      );

      isLoading.value = false;
      Get.offAll(() => const LoginPage());
    } catch (e) {
      isLoading.value = false;
      _showError(e.toString());
    }
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _resetPasswordUseCase(email);

      final isSuccess = result.fold<bool>(
        (failure) {
          isLoading.value = false;
          _showError(failure.message);
          return false;
        },
        (_) {
          isLoading.value = false;
          Get.snackbar(
            S.current.success,
            S.current.resetPasswordSuccess,
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        },
      );
      return isSuccess;
    } catch (e) {
      isLoading.value = false;
      _showError(e.toString());
      return false;
    }
  }

  // Set Skip Login
  Future<void> setSkipLogin(bool skipped) async {
    await _setSkipLoginUseCase(skipped);
  }

  void _showError(String message) {
    Get.snackbar(
      S.current.error,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser.value != null;
}
