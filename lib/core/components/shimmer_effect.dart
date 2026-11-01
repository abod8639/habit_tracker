import 'package:flutter/material.dart';

/// Tactile Neumorphic Shimmer Effect.
///
/// Sweeps an ambient directional light gradient across child widgets matching
/// the application's unified top-left Neumorphic lighting angle.
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1600),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ShimmerEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final defaultHighlight = isDark
        ? Color.lerp(primary, Colors.white, 0.40)!.withValues(alpha: 0.35)
        : Color.lerp(primary, Colors.white, 0.65)!.withValues(alpha: 0.45);

    final highlight = widget.highlightColor ?? defaultHighlight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final t = _controller.value;
            // Sweep smoothly from -1.0 to 2.0
            final slide = (t * 3.0) - 1.0;
            return LinearGradient(
              begin: Alignment(slide - 1.0, -0.4),
              end: Alignment(slide + 1.0, 0.4),
              colors: [
                Colors.transparent,
                highlight.withValues(alpha: isDark ? 0.08 : 0.06),
                highlight,
                highlight.withValues(alpha: isDark ? 0.08 : 0.06),
                Colors.transparent,
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

