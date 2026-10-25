import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';

/// An elite, tactile Neumorphic / Soft UI action button.
/// Features authentic dual-light extrusion physics, radiant primary blooms,
/// convex surface specular reflections, haptic feedback, and responsive scale micro-animations.
class NeumorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
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
    this.trailingIcon,
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
  bool _isHovered = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _handleTapDown(TapDownDetails _) {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final effectiveAccent = widget.accentColor ?? colorScheme.primary;
    final effectiveRadius = widget.borderRadius ?? AppRadius.lgRadius;

    // ── Primary Gradient Tokens (Convex Curved Sheen) ────────────────────────
    final Color primaryStart =
        ThemeUtils.accentGradientStart(effectiveAccent, isDark);
    final Color primaryEnd =
        ThemeUtils.accentGradientEnd(effectiveAccent, isDark);

    // ── Secondary / Surface Gradient Tokens ──────────────────────────────────
    final Color surfaceStart =
        ThemeUtils.surfaceGradientStart(baseColor, isDark);
    final Color surfaceEnd =
        ThemeUtils.surfaceGradientEnd(baseColor, isDark);

    // ── Background Gradients ─────────────────────────────────────────────────
    final Gradient? backgroundGradient = !_isEnabled
        ? null
        : _isPressed
        ? (widget.isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryEnd, primaryStart],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [surfaceEnd, surfaceStart],
                ))
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

    final Color? solidDisabledColor = !_isEnabled
        ? ThemeUtils.disabledSurfaceColor(isDark)
        : null;

    // ── Neumorphic Shadow Engine with Radiant Primary Bloom ───────────────────
    final List<BoxShadow> effectiveShadows;
    if (!_isEnabled) {
      effectiveShadows = const [];
    } else if (_isPressed) {
      if (widget.isPrimary) {
        effectiveShadows = AppShadows.buttonPressed(isDark: isDark);
      } else {
        effectiveShadows = AppShadows.buttonPressed(isDark: isDark);
      }
    } else {
      if (widget.isPrimary) {
        effectiveShadows = AppShadows.buttonResting(isDark: isDark);
      } else {
        effectiveShadows = AppShadows.buttonResting(isDark: isDark);
      }
    }

    // ── Text & Icon Colors ───────────────────────────────────────────────────
    final Color effectiveTextColor =
        widget.textColor ??
        (!_isEnabled
            ? theme.disabledColor
            : widget.isPrimary
            ? colorScheme.onPrimary
            : colorScheme.onSurface);

    // Dynamic Scale: Pressed (indented) vs Hovered (slight float) vs Resting
    final double targetScale = _isPressed
        ? 0.965
        : (_isHovered && _isEnabled ? 1.015 : 1.0);

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.text,
      child: MouseRegion(
        cursor: _isEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _isEnabled ? widget.onPressed : null,
          child: AnimatedScale(
            scale: targetScale,
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              width: widget.width,
              height: widget.height,
              padding:
                  widget.padding ?? const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: effectiveRadius,
                gradient: backgroundGradient,
                color: solidDisabledColor,
                border: Border.all(
                  color: !_isEnabled
                      ? Colors.transparent
                      : widget.isPrimary
                      ? colorScheme.onPrimary.withValues(
                          alpha: _isPressed
                              ? (isDark ? 0.10 : 0.20)
                              : (isDark ? 0.22 : 0.42),
                        )
                      : ThemeUtils.subtleBorderColor(
                          isDark,
                          isPressed: _isPressed,
                        ),
                  width: 1.2,
                ),
                boxShadow: effectiveShadows,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: child,
                    ),
                  ),
                  child: widget.isLoading
                      ? SizedBox(
                          key: const ValueKey('loading_indicator'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: effectiveTextColor,
                          ),
                        )
                      : Row(
                          key: const ValueKey('button_content'),
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: 19,
                                color: effectiveTextColor,
                                shadows: widget.isPrimary && _isEnabled
                                    ? [
                                        Shadow(
                                          color: AppShadows.darkShadowColor(isDark)
                                              .withValues(
                                                alpha: isDark ? 0.35 : 0.20,
                                              ),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                widget.text,
                                style:
                                    widget.textStyle ??
                                    TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: effectiveTextColor,
                                      letterSpacing: 0.2,
                                      shadows: widget.isPrimary && _isEnabled
                                          ? [
                                              Shadow(
                                                color: AppShadows.darkShadowColor(
                                                  isDark,
                                                ).withValues(
                                                  alpha: isDark ? 0.35 : 0.20,
                                                ),
                                                offset: const Offset(0, 1),
                                                blurRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.trailingIcon != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                widget.trailingIcon,
                                size: 19,
                                color: effectiveTextColor,
                                shadows: widget.isPrimary && _isEnabled
                                    ? [
                                        Shadow(
                                          color: AppShadows.darkShadowColor(
                                            isDark,
                                          ).withValues(
                                            alpha: isDark ? 0.35 : 0.20,
                                          ),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
