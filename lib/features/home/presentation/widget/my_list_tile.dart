import 'package:flutter/material.dart';

/// Material 3 Navigation Drawer Tile
class MyDrawerListTile extends StatefulWidget {
  final Widget? icon;
  final String title;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? trailing;

  const MyDrawerListTile({
    this.onTap,
    this.icon,
    this.title = "test",
    this.isSelected = false,
    this.trailing,
    super.key,
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

    // Neumorphic dual shadows
    final List<BoxShadow> shadows;
    if (widget.isSelected) {
      // Concave / recessed soft glow feel
      shadows = [
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.02)
              : Colors.white.withValues(alpha: 0.6),
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.35)
              : const Color(0xFFA3B1C6).withValues(alpha: 0.25),
          offset: const Offset(2, 2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.15),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: -1,
        ),
      ];
    } else if (_isHovered) {
      // Hovered: enhanced elevation
      shadows = [
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.95),
          offset: const Offset(-3.5, -3.5),
          blurRadius: 7,
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.55)
              : const Color(0xFFA3B1C6).withValues(alpha: 0.45),
          offset: const Offset(3.5, 3.5),
          blurRadius: 7,
        ),
      ];
    } else {
      // Resting soft UI elevation
      shadows = [
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.045)
              : Colors.white.withValues(alpha: 0.85),
          offset: const Offset(-2.5, -2.5),
          blurRadius: 5,
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.45)
              : const Color(0xFFA3B1C6).withValues(alpha: 0.35),
          offset: const Offset(2.5, 2.5),
          blurRadius: 5,
        ),
      ];
    }

    // Subtle tactile gradient
    final Gradient? gradient;
    if (widget.isSelected) {
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            isDark
                ? Colors.black.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.03),
            surfaceColor,
          ),
          surfaceColor,
        ],
      );
    } else {
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          surfaceColor,
          Color.alphaBlend(
            isDark
                ? Colors.black.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.03),
            surfaceColor,
          ),
        ],
      );
    }

    // Border styling
    final Border border;
    if (widget.isSelected) {
      border = Border.all(
        color: colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.25),
        width: 1.0,
      );
    } else {
      border = Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.65),
        width: 1.0,
      );
    }

    final Color foregroundColor = widget.isSelected
        ? colorScheme.primary
        : colorScheme.onSurface;

    final Color iconColor = widget.isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOutCubic,
          height: 52.0,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16.0),
            gradient: gradient,
            boxShadow: shadows,
            border: border,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: _handleTap,
              onHover: (hovered) {
                if (_isHovered != hovered) {
                  setState(() => _isHovered = hovered);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          color: iconColor,
                          size: 22.0,
                        ),
                        child: widget.icon!,
                      ),
                      const SizedBox(width: 12.0),
                    ],
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOutCubic,
                        style: (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
                          fontSize: 14.5,
                          fontWeight: widget.isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: foregroundColor,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: Text(widget.title),
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 8.0),
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
