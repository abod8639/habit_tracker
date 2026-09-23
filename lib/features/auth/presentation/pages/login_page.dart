import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/login_page_icon.dart';
import 'package:habit_tracker/features/auth/presentation/pages/signup_page.dart';
import 'package:habit_tracker/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:habit_tracker/features/home/presentation/pages/home_screen.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/fade_slide_transition.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/sync_controller.dart';
import 'package:habit_tracker/core/functions/perform_sync.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final HabitController _habitController = Get.find<HabitController>();
  final SyncController _syncController = Get.find<SyncController>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    if (_formKey.currentState!.validate()) {
      final success = await _authController.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (success) {
        await performSync(_syncController, _habitController);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await _authController.signInWithGoogle();
    if (success) {
      await performSync(_syncController, _habitController);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const delayStep = Duration(milliseconds: 100);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Skip Button
                  AnimatedEntry(
                    delay: Duration.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await _authController.setSkipLogin(true);
                            Get.offAll(() => const HomeScreen());
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.secondary,
                          ),
                          child: Text(S.current.skipNow),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header Icon
                  AnimatedEntry(
                    delay: delayStep,
                    child: LoginPageIcon(theme: theme),
                  ),

                  const SizedBox(height: 48),

                  // Email Field
                  AnimatedEntry(
                    delay: delayStep * 2,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: S.current.email,
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerLowest,
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
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  AnimatedEntry(
                    delay: delayStep * 3,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: S.current.password,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerLowest,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return S.current.passwordRequired;
                        }
                        if (value.length < 6) {
                          return S.current.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Forgot Password
                  AnimatedEntry(
                    delay: delayStep * 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.to(() => const ForgotPasswordPage());
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.secondary,
                        ),
                        child: Text(S.current.forgotPassword),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign In Button
                  AnimatedEntry(
                    delay: delayStep * 4,
                    child: Obx(() {
                      final bool isAuthLoading =
                          _authController.isLoading.value;
                      final bool isSyncing =
                          _syncController.syncStatus.value ==
                          SyncStatus.syncing;
                      final bool isLoading = isAuthLoading || isSyncing;

                      return ElevatedButton(
                        onPressed: isLoading ? null : _handleEmailSignIn,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                S.current.login,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  AnimatedEntry(
                    delay: delayStep * 5,
                    child: Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            S.current.or,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Google Sign In Button
                  AnimatedEntry(
                    delay: delayStep * 9,
                    child: Obx(() {
                      final bool isAuthLoading =
                          _authController.isLoading.value;
                      final bool isSyncing =
                          _syncController.syncStatus.value ==
                          SyncStatus.syncing;
                      final bool isLoading = isAuthLoading || isSyncing;

                      return OutlinedButton.icon(
                        onPressed: isLoading ? null : _handleGoogleSignIn,
                        icon: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Image.asset(
                                'assets/icon/google_icon.png',
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.g_mobiledata,
                                    size: 24,
                                  );
                                },
                              ),
                        label: Text(S.current.signInWithGoogle),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Sign Up Link
                  AnimatedEntry(
                    delay: delayStep * 7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.current.dontHaveAccount,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const SignUpPage());
                          },
                          child: Text(
                            S.current.createAccount,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
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
