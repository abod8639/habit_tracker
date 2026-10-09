import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A premium Neumorphic Pill Segmented Toggle with deep physical recess,
/// smooth sliding indicator animation, tactile haptics, and directional RTL/LTR support.
class NeumorphicPillToggle extends StatefulWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<IconData>? icons;
  final bool isExpanded;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? activeColor;
  final Color? activeSecondaryColor;

  const NeumorphicPillToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    this.icons,
    this.isExpanded = false,
    this.height = 36.0,
    this.padding = const EdgeInsets.all(3.5),
    this.activeColor,
    this.activeSecondaryColor,
  });

  @override
  State<NeumorphicPillToggle> createState() => _NeumorphicPillToggleState();
}

class _NeumorphicPillToggleState extends State<NeumorphicPillToggle> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.options.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final primary = widget.activeColor ?? colorScheme.primary;
    final secondary = widget.activeSecondaryColor ??
        (Color.lerp(primary, Colors.black, isDark ? 0.22 : 0.12) ?? primary);

    // Deep recessed track color and ambient inner shadow gradient
    final wellBase = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.28) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.35) ?? baseColor);

    final trackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        isDark
            ? (Color.lerp(wellBase, Colors.black, 0.30) ?? wellBase)
            : (Color.lerp(wellBase, const Color(0xFFC5D1E0), 0.38) ?? wellBase),
        isDark
            ? (Color.lerp(wellBase, Colors.white, 0.04) ?? wellBase)
            : (Color.lerp(wellBase, Colors.white, 0.50) ?? wellBase),
      ],
    );

    final safeIndex = widget.selectedIndex.clamp(0, widget.options.length - 1);
    final resolvedPadding = widget.padding.resolve(Directionality.of(context));

    const textStyle = TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    if (widget.isExpanded) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = resolvedPadding.horizontal;
          final segmentWidth =
              (constraints.maxWidth - horizontalPadding) / widget.options.length;
          return _buildToggle(
            context: context,
            segmentWidth: math.max(segmentWidth, 0.0),
            safeIndex: safeIndex,
            isDark: isDark,
            trackGradient: trackGradient,
            primary: primary,
            secondary: secondary,
            textStyle: textStyle,
            resolvedPadding: resolvedPadding,
          );
        },
      );
    }

    final segmentWidth = _calculateSegmentWidth(context, textStyle);
    return _buildToggle(
      context: context,
      segmentWidth: segmentWidth,
      safeIndex: safeIndex,
      isDark: isDark,
      trackGradient: trackGradient,
      primary: primary,
      secondary: secondary,
      textStyle: textStyle,
      resolvedPadding: resolvedPadding,
    );
  }

  double _calculateSegmentWidth(BuildContext context, TextStyle textStyle) {
    double maxContentWidth = 0.0;
    final direction = Directionality.of(context);

    for (int i = 0; i < widget.options.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(text: widget.options[i], style: textStyle),
        textDirection: direction,
        maxLines: 1,
      )..layout();

      double itemWidth = textPainter.width + 26.0;
      if (widget.icons != null && i < widget.icons!.length) {
        itemWidth += 19.5; // icon (14.5) + spacing (5)
      }
      if (itemWidth > maxContentWidth) {
        maxContentWidth = itemWidth;
      }
    }
    return math.max(maxContentWidth, 68.0);
  }

  Widget _buildToggle({
    required BuildContext context,
    required double segmentWidth,
    required int safeIndex,
    required bool isDark,
    required Gradient trackGradient,
    required Color primary,
    required Color secondary,
    required TextStyle textStyle,
    required EdgeInsets resolvedPadding,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalInnerWidth = segmentWidth * widget.options.length;
    final innerHeight =
        math.max(widget.height - resolvedPadding.vertical, 24.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        height: widget.height,
        padding: resolvedPadding,
        decoration: BoxDecoration(
          gradient: trackGradient,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.85),
            width: 1.0,
          ),
          boxShadow: AppShadows.wellDual(isDark: isDark),
        ),
        child: SizedBox(
          width: totalInnerWidth,
          height: innerHeight,
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              // ── Sliding Extruded Physical Pill Indicator ──
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOutCubic,
                start: safeIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: AnimatedScale(
                  scale: _isPressed ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.well),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(
                                primary,
                                Colors.white,
                                isDark ? 0.20 : 0.28,
                              ) ??
                              primary,
                          primary,
                          secondary,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: isDark ? 0.32 : 0.90,
                        ),
                        width: 1.0,
                      ),
                      boxShadow: [
                        // Top-left physical specular highlight reflection
                        BoxShadow(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.85),
                          offset: const Offset(-1.5, -1.5),
                          blurRadius: 3.0,
                        ),
                        // Bottom-right physical extruded cast shadow
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.65)
                              : const Color(0xFFA3B1C6).withValues(alpha: 0.50),
                          offset: const Offset(2.0, 2.5),
                          blurRadius: 5.0,
                          spreadRadius: 0.2,
                        ),
                        // Radiant accent color bloom
                        BoxShadow(
                          color: primary.withValues(
                            alpha: isDark ? 0.45 : 0.32,
                          ),
                          blurRadius: 9.0,
                          offset: const Offset(0, 2.5),
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Interactive Segment Options ──
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.options.length, (index) {
                  final isSelected = index == safeIndex;
                  final hasIcon =
                      widget.icons != null && index < widget.icons!.length;

                  final targetTextColor = isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) {
                      setState(() {
                        _isPressed = true;
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        _isPressed = false;
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        _isPressed = false;
                      });
                    },
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onSelect(index);
                    },
                    child: SizedBox(
                      width: segmentWidth,
                      height: innerHeight,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasIcon) ...[
                              TweenAnimationBuilder<Color?>(
                                duration: const Duration(milliseconds: 200),
                                tween: ColorTween(
                                  begin: targetTextColor,
                                  end: targetTextColor,
                                ),
                                builder: (context, color, _) {
                                  return Icon(
                                    widget.icons![index],
                                    size: 14.5,
                                    color: color,
                                  );
                                },
                              ),
                              const SizedBox(width: 5),
                            ],
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              style: textStyle.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: targetTextColor,
                                shadows: isSelected
                                    ? [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: isDark ? 0.35 : 0.20,
                                          ),
                                          offset: const Offset(0, 1.0),
                                          blurRadius: 1.5,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                widget.options[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
