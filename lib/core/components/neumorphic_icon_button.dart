import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A reusable, tactile Neumorphic icon button.
/// Supports both squircle (rounded rectangle) and circular shapes,
/// smooth press-in physical depth feedback, adaptive lighting gradients,
/// and unified shadows from [AppShadows].
class NeumorphicIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? accentColor;
  final Color? iconColor;
  final double size;
  final double? iconSize;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final bool glowWithAccent;
  final List<BoxShadow>? customShadows;

  const NeumorphicIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.accentColor,
    this.iconColor,
    this.size = 46.0,
    this.iconSize,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.glowWithAccent = false,
    this.customShadows,
  });

  const NeumorphicIconButton.circle({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.accentColor,
    this.iconColor,
    this.size = 42.0,
    this.iconSize,
    this.glowWithAccent = false,
    this.customShadows,
  })  : shape = BoxShape.circle,
        borderRadius = null;

  const NeumorphicIconButton.square({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.accentColor,
    this.iconColor,
    this.size = 46.0,
    this.iconSize = 22.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.glowWithAccent = false,
    this.customShadows,
  }) : shape = BoxShape.rectangle;

  @override
  State<NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final colorScheme = theme.colorScheme;

    final Color surfaceStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.16) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    final Color effectiveIconColor = widget.iconColor ??
        widget.accentColor ??
        colorScheme.onSurface;

    final double effectiveIconSize = widget.iconSize ?? (widget.size * 0.48);

    final BorderRadius? effectiveBorderRadius = widget.shape == BoxShape.circle
        ? null
        : (widget.borderRadius ?? const BorderRadius.all(Radius.circular(16.0)));

    final List<BoxShadow> effectiveShadows = widget.customShadows ??
        (_isPressed
            ? (widget.shape == BoxShape.circle
                ? AppShadows.buttonPressed(isDark: isDark)
                : AppShadows.softButtonPressed(isDark: isDark))
            : [
                ...(widget.shape == BoxShape.circle
                    ? AppShadows.buttonResting(isDark: isDark)
                    : AppShadows.softButton(isDark: isDark)),
                if (widget.glowWithAccent &&
                    (widget.accentColor != null || widget.iconColor != null))
                  BoxShadow(
                    color: (widget.accentColor ?? widget.iconColor)!.withValues(
                      alpha: isDark ? 0.25 : 0.15,
                    ),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
              ]);

    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: effectiveBorderRadius,
            gradient: _isPressed
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [surfaceStart, surfaceEnd],
                  ),
            color: _isPressed
                ? (isDark
                    ? Colors.black.withValues(alpha: 0.32)
                    : const Color(0xFFD3DCE8))
                : null,
            border: Border.all(
              color: (widget.glowWithAccent && widget.accentColor != null)
                  ? widget.accentColor!.withValues(alpha: isDark ? 0.35 : 0.25)
                  : (isDark
                      ? Colors.white.withValues(alpha: _isPressed ? 0.03 : 0.06)
                      : Colors.white.withValues(alpha: _isPressed ? 0.35 : 0.80)),
              width: 1.0,
            ),
            boxShadow: effectiveShadows,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: effectiveIconSize,
              color: effectiveIconColor,
              shadows: AppShadows.buttonPressed(isDark: isDark),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
