import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/core/theme/theme_utils.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Fully tactile Neumorphic / Soft UI Confirmation Dialog.
///
/// Features authentic dual-source ambient lighting, a sculpted 3D header badge,
/// soft card contours, debossed wells, and tactile interactive Neumorphic action buttons.
class AppConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? confirmText;
  final String? cancelText;
  final bool isDestructive;
  final Widget? customContent;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.confirmText,
    this.cancelText,
    this.isDestructive = false,
    this.customContent,
    this.onConfirm,
    this.onCancel,
  });

  /// Displays the confirmation dialog and returns true if confirmed, false otherwise.
  static Future<bool?> show({
    BuildContext? context,
    required String title,
    required String message,
    IconData? icon,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    Widget? customContent,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    final targetContext = context ?? Get.overlayContext ?? Get.context;
    if (targetContext == null) return Future.value(false);

    return showDialog<bool>(
      context: targetContext,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) => AppConfirmationDialog(
        title: title,
        message: message,
        icon: icon,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        customContent: customContent,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<AppConfirmationDialog> createState() => _AppConfirmationDialogState();
}

class _AppConfirmationDialogState extends State<AppConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final primaryColor = widget.isDestructive
        ? themeColors.error
        : themeColors.primary;

    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            decoration: BoxDecoration(
              borderRadius: AppRadius.dialogRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [surfaceGradientStart, surfaceGradientEnd],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: AppShadows.softCard(isDark: isDark),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Tactile Neumorphic Header Badge ─────────────────────────
                if (widget.icon != null) ...[
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.alphaBlend(
                        primaryColor.withValues(alpha: isDark ? 0.16 : 0.10),
                        baseColor,
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.90),
                        width: 1.0,
                      ),
                      boxShadow: [
                        ...AppShadows.badge(isDark: isDark),
                        ...AppShadows.bloom(
                          color: primaryColor,
                          isDark: isDark,
                          blur: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: primaryColor,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Dialog Title ────────────────────────────────────────────
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                    fontSize: 19,
                    color: themeColors.onSurface,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Message Body ────────────────────────────────────────────
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: themeColors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),

                // ── Custom Content (e.g. Habit preview well) ────────────────
                if (widget.customContent != null) ...[
                  const SizedBox(height: 14),
                  widget.customContent!,
                ],

                const SizedBox(height: 22),

                // ── Tactile Neumorphic Action Buttons ───────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _NeumorphicDialogButton(
                        label: widget.cancelText ?? S.of(context).cancel,
                        icon: Icons.close_rounded,
                        isPrimary: false,
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          widget.onCancel?.call();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NeumorphicDialogButton(
                        label:
                            widget.confirmText ??
                            (widget.isDestructive
                                ? S.of(context).delete
                                : S.of(context).save),
                        icon: widget.isDestructive
                            ? Icons.delete_outline_rounded
                            : Icons.check_rounded,
                        isPrimary: true,
                        primaryColor: primaryColor,
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          widget.onConfirm?.call();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tactile Neumorphic Button with press-in physical depth feedback.
class _NeumorphicDialogButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final Color? primaryColor;
  final VoidCallback onPressed;

  const _NeumorphicDialogButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    this.primaryColor,
    required this.onPressed,
  });

  @override
  State<_NeumorphicDialogButton> createState() =>
      _NeumorphicDialogButtonState();
}

class _NeumorphicDialogButtonState extends State<_NeumorphicDialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final primaryColor = widget.primaryColor ?? colorScheme.primary;

    final Color surfaceColor;
    if (widget.isPrimary) {
      surfaceColor = primaryColor;
    } else {
      surfaceColor = isDark
          ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
          : (Color.lerp(baseColor, Colors.white, 0.50) ?? baseColor);
    }

    final Color textColor = widget.isPrimary
        ? ThemeUtils.getContrastColor(primaryColor)
        : colorScheme.onSurfaceVariant;

    final Color iconColor = widget.isPrimary
        ? textColor
        : colorScheme.onSurfaceVariant;

    final List<BoxShadow> shadows;
    if (_isPressed) {
      shadows = AppShadows.buttonPressed(isDark: isDark);
    } else if (widget.isPrimary) {
      shadows = [
        ...AppShadows.bloom(
          color: primaryColor,
          isDark: isDark,
          blur: 10,
          spread: 0.5,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.85),
          offset: const Offset(-2, -2),
          blurRadius: 5,
        ),
      ];
    } else {
      shadows = AppShadows.buttonResting(isDark: isDark);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: AppRadius.mdRadius,
          gradient: widget.isPrimary
              ? LinearGradient(
                  colors: [
                    primaryColor,
                    Color.lerp(
                          primaryColor,
                          Colors.black,
                          isDark ? 0.20 : 0.10,
                        ) ??
                        primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Color.lerp(
                      surfaceColor,
                      Colors.white,
                      isDark ? 0.04 : 0.40,
                    )!,
                    Color.lerp(
                      surfaceColor,
                      isDark ? Colors.black : const Color(0xFFA3B1C6),
                      isDark ? 0.12 : 0.08,
                    )!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(
            color: widget.isPrimary
                ? Colors.white.withValues(alpha: isDark ? 0.15 : 0.40)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.85)),
            width: 1.0,
          ),
          boxShadow: shadows,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: iconColor,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
