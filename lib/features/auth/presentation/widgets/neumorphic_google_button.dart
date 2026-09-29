import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

class NeumorphicGoogleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const NeumorphicGoogleButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.label,
  });

  @override
  State<NeumorphicGoogleButton> createState() => _NeumorphicGoogleButtonState();
}

class _NeumorphicGoogleButtonState extends State<NeumorphicGoogleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.05) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.55) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.18) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.12) ?? baseColor);

    final bool isInteractive = !widget.isLoading && widget.onPressed != null;

    final List<BoxShadow> shadows = (_isPressed || widget.isLoading)
        ? (isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.50),
                  offset: const Offset(1.5, 1.5),
                  blurRadius: 3.0,
                ),
              ]
            : [
                const BoxShadow(
                  color: Color(0x55A3B1C6),
                  offset: Offset(1.5, 1.5),
                  blurRadius: 3.0,
                ),
              ])
        : AppShadows.softButton(isDark: isDark);

    return GestureDetector(
      onTapDown: isInteractive ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isInteractive
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isInteractive ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
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
                  : Colors.white.withValues(alpha: _isPressed ? 0.40 : 0.90),
              width: 1.2,
            ),
            boxShadow: shadows,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: theme.colorScheme.primary,
                  ),
                )
              else ...[
                Image.asset(
                  'assets/icon/google_icon.png',
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.g_mobiledata,
                      size: 26,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.3,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
