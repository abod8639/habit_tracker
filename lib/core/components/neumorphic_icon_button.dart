import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A reusable, tactile Neumorphic circular icon button.
/// Provides smooth press-in physical depth feedback, adaptive lighting gradients,
/// and unified shadows from [AppShadows].
class NeumorphicIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? accentColor;
  final double size;
  final double? iconSize;

  const NeumorphicIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.accentColor,
    this.size = 42.0,
    this.iconSize,
  });

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
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    final Color effectiveIconColor =
        widget.accentColor ?? colorScheme.onSurface;

    final double effectiveIconSize = widget.iconSize ?? (widget.size * 0.50);

    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isPressed
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [surfaceStart, surfaceEnd],
                ),
          color: _isPressed
              ? (isDark
                  ? Colors.black.withValues(alpha: 0.30)
                  : const Color(0xFFD3DCE8))
              : null,
          border: Border.all(
            color: widget.accentColor != null
                ? widget.accentColor!.withValues(alpha: isDark ? 0.35 : 0.25)
                : (isDark
                    ? Colors.white.withValues(alpha: _isPressed ? 0.03 : 0.07)
                    : Colors.white.withValues(alpha: _isPressed ? 0.40 : 0.85)),
            width: 1.0,
          ),
          boxShadow: _isPressed
              ? AppShadows.buttonPressed(isDark: isDark)
              : [
                  ...AppShadows.buttonResting(isDark: isDark),
                  if (widget.accentColor != null)
                    BoxShadow(
                      color: widget.accentColor!.withValues(
                        alpha: isDark ? 0.25 : 0.15,
                      ),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                ],
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: effectiveIconSize,
            color: effectiveIconColor,
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
