import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/core/theme/theme_utils.dart';

/// Depth of a Neumorphic surface: extruded from the background or pressed into it.
enum NeuDepth { raised, inset }

/// Single-material Neumorphic surface used across the plan generator.
///
/// Neumorphism keeps every surface the same material as the background and
/// expresses hierarchy only through light (top-left highlight, bottom-right
/// shadow). Accent colors live in content (icons, text), not in fills, so
/// [accentColor] only adds a soft bloom to raised, highlighted surfaces.
/// When [onTap] is set the surface physically presses in while touched.
class NeuSurface extends StatefulWidget {
  final Widget child;
  final NeuDepth depth;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final BoxShape shape;
  final double? width;
  final double? height;
  final Color? accentColor;
  final bool highlighted;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const NeuSurface({
    super.key,
    required this.child,
    this.depth = NeuDepth.raised,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppRadius.cardRadius,
    this.shape = BoxShape.rectangle,
    this.width,
    this.height,
    this.accentColor,
    this.highlighted = false,
    this.onTap,
    this.shadows,
  });

  @override
  State<NeuSurface> createState() => _NeuSurfaceState();
}

class _NeuSurfaceState extends State<NeuSurface> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final isInset = widget.depth == NeuDepth.inset || _isPressed;
    final isCircle = widget.shape == BoxShape.circle;

    final List<BoxShadow> shadows =
        widget.shadows ?? AppShadows.softCard(isDark: isDark);

    Widget surface = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        shape: widget.shape,
        borderRadius: isCircle ? null : widget.borderRadius,
        color: isInset
            ? ThemeUtils.debossedSurfaceColor(baseColor, isDark)
            : null,
        gradient: isInset
            ? null
            : ThemeUtils.softGradient(baseColor: baseColor, isDark: isDark),
        border: Border.all(
          color: ThemeUtils.subtleBorderColor(isDark, isPressed: isInset),
          width: 1,
        ),
        boxShadow: shadows,
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      surface = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: surface,
          ),
        ),
      );
    }

    return surface;
  }
}

/// Small Neumorphic pill for tags, stats and badges. Inset by default so it
/// reads as engraved into its parent card.
class NeuChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final Color color;
  final NeuDepth depth;
  final double fontSize;
  final Widget? trailing;

  const NeuChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.emoji,
    this.depth = NeuDepth.inset,
    this.fontSize = 11,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return NeuSurface(
      depth: depth,
      borderRadius: AppRadius.pillRadius,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null)
            Text(emoji!, style: TextStyle(fontSize: fontSize))
          else if (icon != null)
            Icon(icon, size: fontSize + 2, color: color),
          if (emoji != null || icon != null) const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 5), trailing!],
        ],
      ),
    );
  }
}

/// Extruded circular orb holding an icon or emoji (headers, trophies, steps).
class NeuOrb extends StatelessWidget {
  final double size;
  final IconData? icon;
  final String? emoji;
  final Color? color;
  final NeuDepth depth;
  final bool glow;

  const NeuOrb({
    super.key,
    this.size = 44,
    this.icon,
    this.emoji,
    this.color,
    this.depth = NeuDepth.raised,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return NeuSurface(
      shape: BoxShape.circle,
      depth: depth,
      width: size,
      height: size,
      padding: EdgeInsets.zero,
      accentColor: effectiveColor,
      highlighted: glow,
      child: Center(
        child: emoji != null
            ? Text(emoji!, style: TextStyle(fontSize: size * 0.42))
            : Icon(icon, size: size * 0.46, color: effectiveColor),
      ),
    );
  }
}
