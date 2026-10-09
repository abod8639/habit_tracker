import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A reusable, tactile Neumorphic / Soft UI selection tile.
/// Used for single choice options, multiple choice selections,
/// category tiles, and item toggles with unified lighting tokens.
class NeumorphicSelectionTile extends StatefulWidget {
  final Widget? title;
  final String? titleText;
  final Widget? subtitle;
  final String? subtitleText;
  final Widget? leading;
  final Widget? trailing;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool showDefaultIndicator;
  final bool isMultiple;

  const NeumorphicSelectionTile({
    super.key,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.leading,
    this.trailing,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.showDefaultIndicator = true,
    this.isMultiple = false,
  });

  @override
  State<NeumorphicSelectionTile> createState() => _NeumorphicSelectionTileState();
}

class _NeumorphicSelectionTileState extends State<NeumorphicSelectionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final effectiveAccent = widget.accentColor ?? colorScheme.primary;
    final effectiveRadius = widget.borderRadius ?? AppRadius.mdRadius;

    final Color surfaceStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.35) ?? baseColor);

    final Color surfaceEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.16) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    final Color borderColor = widget.isSelected
        ? effectiveAccent.withValues(alpha: isDark ? 0.65 : 0.45)
        : (isDark
            ? Colors.white.withValues(alpha: _isPressed ? 0.03 : 0.06)
            : Colors.white.withValues(alpha: _isPressed ? 0.35 : 0.85));

    final List<BoxShadow> effectiveShadows = widget.isSelected
        ? AppShadows.selectedCard(primary: effectiveAccent, isDark: isDark)
        : (_isPressed
            ? AppShadows.softButtonPressed(isDark: isDark)
            : AppShadows.tileResting(isDark: isDark));

    final Widget? effectiveLeading = widget.leading;

    final Widget? effectiveTrailing = widget.trailing ??
        (widget.showDefaultIndicator
            ? AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: widget.isMultiple ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: widget.isMultiple ? BorderRadius.circular(6) : null,
                  color: widget.isSelected ? effectiveAccent : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected
                        ? effectiveAccent
                        : (isDark ? Colors.white.withValues(alpha: 0.20) : const Color(0xFFA3B1C6)),
                    width: 1.5,
                  ),
                  boxShadow: widget.isSelected
                      ? AppShadows.activeDot(color: effectiveAccent)
                      : null,
                ),
                child: widget.isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      )
                    : null,
              )
            : null);

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 6.0),
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.isSelected
                      ? Color.alphaBlend(
                          effectiveAccent.withValues(alpha: isDark ? 0.16 : 0.10),
                          surfaceStart,
                        )
                      : surfaceStart,
                  widget.isSelected
                      ? Color.alphaBlend(
                          effectiveAccent.withValues(alpha: isDark ? 0.22 : 0.14),
                          surfaceEnd,
                        )
                      : surfaceEnd,
                ],
              ),
              border: Border.all(
                color: borderColor,
                width: widget.isSelected ? 1.5 : 1.0,
              ),
              boxShadow: effectiveShadows,
            ),
            child: Row(
              children: [
                if (effectiveLeading != null) ...[
                  effectiveLeading,
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title != null)
                        widget.title!
                      else if (widget.titleText != null)
                        Text(
                          widget.titleText!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: widget.isSelected
                                ? effectiveAccent
                                : colorScheme.onSurface,
                          ),
                        ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        widget.subtitle!,
                      ] else if (widget.subtitleText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitleText!,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.65),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (effectiveTrailing != null) ...[
                  const SizedBox(width: 12),
                  effectiveTrailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
