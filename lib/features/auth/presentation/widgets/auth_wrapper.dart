import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:habit_tracker/features/home/presentation/pages/home_screen.dart';
import '../../domain/usecases/get_skip_login_status_usecase.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;
  bool _hasSkipped = false;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final getSkipStatus = Get.find<GetSkipLoginStatusUseCase>();
    final result = await getSkipStatus();

    result.fold(
      (_) => _hasSkipped = false,
      (status) => _hasSkipped = status,
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser;

      if (user != null || _hasSkipped) {
        return const HomeScreen();
      } else {
        return const LoginPage();
      }
    });
  }
}
