import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/soft_card.dart';

/// Centralized Neumorphism & Soft UI styling utilities for Habit Stats feature.
/// Ensures consistent lighting angles, depth, radii, and responsive contrast
/// across both Dark and Light themes.
class StatsNeumorphicTheme {
  /// Base surface gradient with top-left light source reflection.
  static LinearGradient surfaceGradient(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [surfaceGradientStart, surfaceGradientEnd],
    );
  }

  /// Ambient raised card decoration with dual lighting shadows.
  static BoxDecoration cardDecoration(
    BuildContext context, {
    double borderRadius = 24.0,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color lightShadowColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.9);

    final Color darkShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.65)
        : const Color(0xFFA3B1C6).withValues(alpha: 0.35);

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.8);

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: surfaceGradient(context),
      border: Border.all(
        color: borderColor,
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: lightShadowColor,
          offset: const Offset(-5, -5),
          blurRadius: 12,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: darkShadowColor,
          offset: const Offset(6, 6),
          blurRadius: 14,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// Debossed / recessed well decoration for inner items, chips, and stat panels.
  static BoxDecoration wellDecoration(
    BuildContext context, {
    double borderRadius = 18.0,
    Color? accentColor,
    double accentAlpha = 0.08,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final wellBase = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.22) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.30) ?? baseColor);

    final surfaceColor = accentColor != null
        ? (Color.lerp(wellBase, accentColor, accentAlpha) ?? wellBase)
        : wellBase;

    final Color lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.white.withValues(alpha: 0.85);

    final Color darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : const Color(0xFFA3B1C6).withValues(alpha: 0.30);

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.70);

    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor,
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: lightShadow,
          offset: const Offset(-2, -2),
          blurRadius: 5,
        ),
        BoxShadow(
          color: darkShadow,
          offset: const Offset(2.5, 2.5),
          blurRadius: 5,
        ),
      ],
    );
  }

  /// Circular or pill soft badge decoration.
  static BoxDecoration badgeDecoration(
    BuildContext context, {
    Color? color,
    double borderRadius = 20.0,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final badgeColor = color ?? theme.colorScheme.primary;

    final badgeBase = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.18) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.28) ?? baseColor);

    final surfaceColor = Color.lerp(badgeBase, badgeColor, isDark ? 0.14 : 0.09) ?? badgeBase;

    final lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.85);

    final darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.40)
        : const Color(0xFFA3B1C6).withValues(alpha: 0.28);

    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: badgeColor.withValues(alpha: isDark ? 0.35 : 0.25),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: lightShadow,
          offset: const Offset(-1.5, -1.5),
          blurRadius: 3.5,
        ),
        BoxShadow(
          color: darkShadow,
          offset: const Offset(2.0, 2.0),
          blurRadius: 4.0,
        ),
      ],
    );
  }
}

/// Unified Section Header for all cards in the Habit Stats screen.
class StatsCardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? iconColor;

  const StatsCardHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? colorScheme.primary;

    return  SoftCard(
      child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: StatsNeumorphicTheme.surfaceGradient(context),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.9),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.white.withValues(alpha: 0.9),
                        offset: const Offset(-2, -2),
                        blurRadius: 4,
                      ),
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.45)
                            : const Color(0xFFA3B1C6).withValues(alpha: 0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: effectiveIconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (trailing != null) trailing!,
          ],
        ),
      
    );
  }
}

/// Tactile circular button with micro-press physics and Neumorphic shadows.
class NeumorphicCircularButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? iconColor;
  final String? tooltip;

  const NeumorphicCircularButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 42.0,
    this.iconColor,
    this.tooltip,
  });

  @override
  State<NeumorphicCircularButton> createState() => _NeumorphicCircularButtonState();
}

class _NeumorphicCircularButtonState extends State<NeumorphicCircularButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final iconColor = widget.iconColor ?? colorScheme.onSurface;

    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isPressed
              ? null
              : StatsNeumorphicTheme.surfaceGradient(context),
          color: _isPressed
              ? (isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : const Color(0xFFD3DCE8))
              : null,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: _isPressed ? 0.03 : 0.08)
                : Colors.white.withValues(alpha: _isPressed ? 0.4 : 0.9),
            width: 1.0,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.5)
                        : const Color(0xFFA3B1C6).withValues(alpha: 0.3),
                    offset: const Offset(1.5, 1.5),
                    blurRadius: 3,
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.9),
                    offset: const Offset(-2.5, -2.5),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.5)
                        : const Color(0xFFA3B1C6).withValues(alpha: 0.32),
                    offset: const Offset(3, 3),
                    blurRadius: 6,
                  ),
                ],
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.size * 0.46,
            color: iconColor,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Neumorphic Pill Segmented Toggle (e.g., 7 Days vs 30 Days).
class NeumorphicPillToggle extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const NeumorphicPillToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: StatsNeumorphicTheme.wellDecoration(
        context,
        borderRadius: 22.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.0),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.transparent,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.35 : 0.25,
                          ),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: Icon( 
                isSelected ? Icons.waves : Icons.close_rounded,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                size: 19,
               )
            ),
          );
        }),
      ),
    );
  }
}
