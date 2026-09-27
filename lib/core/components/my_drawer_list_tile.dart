import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// Reusable tactile Neumorphic navigation tile for App Drawers and side menus.
class MyDrawerListTile extends StatefulWidget {
  final Widget? icon;
  final String title;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? trailing;

  const MyDrawerListTile({
    super.key,
    this.onTap,
    this.icon,
    this.title = "test",
    this.isSelected = false,
    this.trailing,
  });

  @override
  State<MyDrawerListTile> createState() => _MyDrawerListTileState();
}

class _MyDrawerListTileState extends State<MyDrawerListTile>
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
      reverseDuration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.99).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() async {
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
    final baseSurface = theme.scaffoldBackgroundColor;

    // Neumorphic surface color calculation
    final Color surfaceColor;
    if (widget.isSelected) {
      surfaceColor = Color.alphaBlend(
        colorScheme.primary.withValues(alpha: isDark ? 0.20 : 0.12),
        baseSurface,
      );
    } else if (_isHovered) {
      surfaceColor = Color.alphaBlend(
        colorScheme.onSurface.withValues(alpha: isDark ? 0.06 : 0.03),
        baseSurface,
      );
    } else {
      surfaceColor = baseSurface;
    }

    // Neumorphic dual shadows from centralized design tokens
    final List<BoxShadow> shadows;
    if (widget.isSelected) {
      shadows = [
        ...AppShadows.insetWell(isDark: isDark),
        ...AppShadows.bloom(
          color: colorScheme.primary,
          isDark: isDark,
          blur: 10,
          spread: -1,
          offset: const Offset(0, 1),
        ),
      ];
    } else if (_isHovered) {
      shadows = AppShadows.subtleCard(isDark: isDark);
    } else {
      shadows = AppShadows.dotIndicator(isDark: isDark);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: AppRadius.mdRadius,
            boxShadow: shadows,
            border: Border.all(
              color: widget.isSelected
                  ? colorScheme.primary.withValues(alpha: isDark ? 0.40 : 0.30)
                  : (isDark
                      ? Colors.white.withValues(alpha: _isHovered ? 0.08 : 0.03)
                      : Colors.white.withValues(alpha: _isHovered ? 0.90 : 0.70)),
              width: widget.isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.mdRadius,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: widget.onTap != null ? _handleTap : null,
              onHover: (hovered) {
                if (_isHovered != hovered) {
                  setState(() => _isHovered = hovered);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          color: widget.isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(
                                  alpha: _isHovered ? 0.90 : 0.70,
                                ),
                          size: 22,
                        ),
                        child: widget.icon!,
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(
                                  alpha: _isHovered ? 1.0 : 0.85,
                                ),
                          fontSize: 14.5,
                          fontWeight: widget.isSelected
                              ? FontWeight.w700
                              : (_isHovered ? FontWeight.w600 : FontWeight.w500),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 8),
                      widget.trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
