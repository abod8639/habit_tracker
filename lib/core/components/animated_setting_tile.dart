import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A reusable Neumorphic animated setting and action tile.
/// Features tactile press feedback, smooth hover states, and unified design tokens.
class AnimatedSettingTile extends StatefulWidget {
  final AnimationController? animationController;
  final int index;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? textColor;

  const AnimatedSettingTile({
    super.key,
    this.animationController,
    this.index = 0,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.textColor,
  });

  @override
  State<AnimatedSettingTile> createState() => _AnimatedSettingTileState();
}

class _AnimatedSettingTileState extends State<AnimatedSettingTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 160),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.onTap == null) return;
    await _pressController.forward();
    if (mounted) {
      await _pressController.reverse();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseSurface = theme.cardColor;
    final primaryColor = widget.textColor ?? theme.primaryColor;

    final Color surfaceColor = _isHovered
        ? Color.alphaBlend(
            colorScheme.onSurface.withValues(alpha: isDark ? 0.05 : 0.02),
            baseSurface,
          )
        : baseSurface;

    // Dual ambient Neumorphic shadows from centralized tokens
    final List<BoxShadow> outerShadows = _isHovered
        ? AppShadows.subtleCard(isDark: isDark)
        : AppShadows.badge(isDark: isDark);

    // Subtle convex gradient
    final Gradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        surfaceColor,
        Color.alphaBlend(
          isDark
              ? Colors.black.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.03),
          surfaceColor,
        ),
      ],
    );

    final Border border = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.70),
      width: 1.0,
    );

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: AppRadius.badgeRadius,
            gradient: gradient,
            boxShadow: outerShadows,
            border: border,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.badgeRadius,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: widget.onTap != null ? _handleTap : null,
              onHover: (hovered) {
                if (_isHovered != hovered) {
                  setState(() => _isHovered = hovered);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildNeumorphicIconBadge(
                      isDark,
                      primaryColor,
                      baseSurface,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: (theme.textTheme.titleMedium ??
                                    const TextStyle())
                                .copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.5,
                              letterSpacing: 0.2,
                              color: widget.textColor ?? colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: (theme.textTheme.bodySmall ??
                                    const TextStyle())
                                .copyWith(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.60),
                              fontSize: 13,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTrailing(isDark, colorScheme, baseSurface),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.animationController != null) {
      final Animation<double> entryAnimation = CurvedAnimation(
        parent: widget.animationController!,
        curve: Interval(
          0.05 * (widget.index % 10),
          math.min(0.05 * (widget.index % 10) + 0.5, 1.0),
          curve: Curves.easeOut,
        ),
      );

      return FadeTransition(
        opacity: entryAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.25, 0),
            end: Offset.zero,
          ).animate(entryAnimation),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildNeumorphicIconBadge(
    bool isDark,
    Color primaryColor,
    Color baseSurface,
  ) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          primaryColor.withValues(alpha: isDark ? 0.14 : 0.09),
          baseSurface,
        ),
        borderRadius: AppRadius.mdRadius,
        boxShadow: AppShadows.dotIndicator(isDark: isDark),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.20 : 0.15),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          widget.icon,
          color: primaryColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildTrailing(
    bool isDark,
    ColorScheme colorScheme,
    Color baseSurface,
  ) {
    if (widget.trailing != null) {
      return widget.trailing!;
    }
    if (widget.onTap != null) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.alphaBlend(
            colorScheme.onSurface.withValues(alpha: isDark ? 0.04 : 0.02),
            baseSurface,
          ),
          boxShadow: AppShadows.dotIndicator(isDark: isDark),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
