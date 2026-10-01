import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.resetPassword(
        email: _emailController.text,
      );

      if (success && mounted) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.resetPasswordTitle),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.current.forgotPassword,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.current.resetPasswordDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: S.current.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.current.emailRequired;
                      }
                      if (!value.contains('@')) {
                        return S.current.emailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Obx(
                    () => ElevatedButton(
                      onPressed: _authController.isLoading.value
                          ? null
                          : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _authController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              S.current.sendResetLink,
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: Text(S.current.backToLogin),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
