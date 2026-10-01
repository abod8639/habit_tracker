import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/functions/perform_sync.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/fade_slide_transition.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/login_page_icon.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/neumorphic_google_button.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/sync_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _handleGoogleSignIn({
    required BuildContext context,
    required AuthController authController,
    required SyncController syncController,
    required HabitController habitController,
  }) async {
    final success = await authController.signInWithGoogle();
    if (success) {
      await performSync(syncController, habitController);
      if (context.mounted) {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final AuthController authController = Get.find<AuthController>();
    final HabitController habitController = Get.find<HabitController>();
    final SyncController syncController = Get.find<SyncController>();

    const delayStep = Duration(milliseconds: 120);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Skip Button (Neumorphic Chip style)
                AnimatedEntry(
                  delay: Duration.zero,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _NeumorphicSkipButton(
                      label: S.current.skipNow,
                      onPressed: () async {
                        await authController.setSkipLogin(true);
                        if (context.mounted) {
                          context.go(AppRoutes.home);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Neumorphic Main Card
                AnimatedEntry(
                  delay: delayStep,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 440),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 36.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          isDark
                              ? (Color.lerp(baseColor, Colors.white, 0.04) ??
                                  baseColor)
                              : (Color.lerp(baseColor, Colors.white, 0.50) ??
                                  baseColor),
                          isDark
                              ? (Color.lerp(baseColor, Colors.black, 0.16) ??
                                  baseColor)
                              : (Color.lerp(
                                    baseColor,
                                    const Color(0xFFA3B1C6),
                                    0.10,
                                  ) ??
                                  baseColor),
                        ],
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.white.withValues(alpha: 0.85),
                        width: 1.2,
                      ),
                      boxShadow: AppShadows.softCard(isDark: isDark),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Soft UI Icon Header
                        LoginPageIcon(theme: theme),

                        const SizedBox(height: 12),

                        // Subtitle / Prompt
                        Text(
                          S.current.login,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 36),

                        // Google Sign-In Only
                        Obx(() {
                          final bool isAuthLoading =
                              authController.isLoading.value;
                          final bool isSyncing =
                              syncController.syncStatus.value ==
                              SyncStatus.syncing;
                          final bool isLoading = isAuthLoading || isSyncing;

                          return NeumorphicGoogleButton(
                            label: S.current.signInWithGoogle,
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => _handleGoogleSignIn(
                                      context: context,
                                      authController: authController,
                                      syncController: syncController,
                                      habitController: habitController,
                                    ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NeumorphicSkipButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _NeumorphicSkipButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_NeumorphicSkipButton> createState() => _NeumorphicSkipButtonState();
}

class _NeumorphicSkipButtonState extends State<_NeumorphicSkipButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.05) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.50) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.16) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.10) ?? baseColor);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.badge),
            gradient: _isPressed
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [surfaceGradientStart, surfaceGradientEnd],
                  ),
            color: _isPressed
                ? (isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFFD6DFEC))
                : null,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: _isPressed ? 0.03 : 0.08)
                  : Colors.white.withValues(alpha: _isPressed ? 0.35 : 0.85),
              width: 1.0,
            ),
            boxShadow: _isPressed
                ? (isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ]
                    : [
                        const BoxShadow(
                          color: Color(0x40A3B1C6),
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ])
                : AppShadows.badge(isDark: isDark),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


