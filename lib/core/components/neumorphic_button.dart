import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A reusable, tactile Neumorphic / Soft UI action button.
/// Supports both vibrant primary bloom states and soft surface extruded states,
/// interactive press-depth physics, loading indicators, and unified tokens.
class NeumorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;
  final Color? accentColor;
  final Color? textColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const NeumorphicButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
    this.accentColor,
    this.textColor,
    this.width,
    this.height = 52.0,
    this.borderRadius,
    this.textStyle,
    this.padding,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final effectiveAccent = widget.accentColor ?? colorScheme.primary;
    final effectiveRadius = widget.borderRadius ?? AppRadius.lgRadius;

    // Surface gradients
    final Color surfaceStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.35) ?? baseColor);

    final Color surfaceEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.16) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.10) ?? baseColor);

    // Primary gradient
    final Color primaryStart = Color.lerp(effectiveAccent, Colors.white, isDark ? 0.08 : 0.12) ?? effectiveAccent;
    final Color primaryEnd = Color.lerp(effectiveAccent, Colors.black, isDark ? 0.16 : 0.10) ?? effectiveAccent;

    // Determine colors
    final Gradient? backgroundGradient = !_isEnabled
        ? null
        : _isPressed
            ? null
            : widget.isPrimary
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryStart, primaryEnd],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [surfaceStart, surfaceEnd],
                  );

    final Color? solidColor = !_isEnabled
        ? (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0))
        : _isPressed
            ? widget.isPrimary
                ? primaryEnd
                : (isDark ? Colors.black.withValues(alpha: 0.32) : const Color(0xFFD3DCE8))
            : null;

    final List<BoxShadow> effectiveShadows = !_isEnabled
        ? const []
        : _isPressed
            ? (widget.isPrimary
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      offset: const Offset(1.5, 1.5),
                      blurRadius: 3.0,
                    ),
                  ]
                : AppShadows.softButtonPressed(isDark: isDark))
            : widget.isPrimary
                ? [
                    ...AppShadows.bloom(
                      color: effectiveAccent,
                      isDark: isDark,
                      blur: 10,
                      spread: 0.8,
                      offset: const Offset(0, 3.5),
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.50)
                          : const Color(0xFFA3B1C6).withValues(alpha: 0.35),
                      offset: const Offset(2.5, 2.5),
                      blurRadius: 5.0,
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.80),
                      offset: const Offset(-2, -2),
                      blurRadius: 4.0,
                    ),
                  ]
                : AppShadows.softButton(isDark: isDark);

    final Color effectiveTextColor = widget.textColor ??
        (!_isEnabled
            ? theme.disabledColor
            : widget.isPrimary
                ? Colors.white
                : colorScheme.onSurface);

    return MouseRegion(
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
        onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            width: widget.width,
            height: widget.height,
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              gradient: backgroundGradient,
              color: solidColor,
              border: Border.all(
                color: !_isEnabled
                    ? Colors.transparent
                    : widget.isPrimary
                        ? Colors.white.withValues(alpha: isDark ? 0.15 : 0.35)
                        : (isDark
                            ? Colors.white.withValues(alpha: _isPressed ? 0.03 : 0.06)
                            : Colors.white.withValues(alpha: _isPressed ? 0.35 : 0.85)),
                width: 1.2,
              ),
              boxShadow: effectiveShadows,
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: effectiveTextColor,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 19,
                            color: effectiveTextColor,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: widget.textStyle ??
                              TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: effectiveTextColor,
                                letterSpacing: 0.3,
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
