import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Neumorphic Color Picker Dialog with 3D color coins.
/// Allows user to tint selected habits with a vibrant palette.
class NeumorphicColorPickerDialog extends StatelessWidget {
  final HabitController controller;

  const NeumorphicColorPickerDialog({super.key, required this.controller});

  static final List<Color> _colors = [
    Colors.red[400]!,
    Colors.pink[400]!,
    Colors.purple[400]!,
    Colors.deepPurple[400]!,
    Colors.indigo[400]!,
    Colors.blue[400]!,
    Colors.lightBlue[400]!,
    Colors.cyan[400]!,
    Colors.teal[400]!,
    Colors.green[400]!,
    Colors.lightGreen[500]!,
    Colors.lime[600]!,
    Colors.yellow[700]!,
    Colors.amber[500]!,
    Colors.orange[600]!,
    Colors.deepOrange[500]!,
    Colors.brown[400]!,
    Colors.blueGrey[400]!,
    const Color(0xFF6C63FF),
    const Color(0xFF2D2D2D),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final baseColor = theme.cardColor;

    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: AppRadius.dialogRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [surfaceGradientStart, surfaceGradientEnd],
          ),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.85),
            width: 1.2,
          ),
          boxShadow: AppShadows.softCard(isDark: isDark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.alphaBlend(
                          colorScheme.primary.withValues(
                            alpha: isDark ? 0.14 : 0.09,
                          ),
                          baseColor,
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.90),
                          width: 1.0,
                        ),
                        boxShadow: AppShadows.badge(isDark: isDark),
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      S.of(context).chooseColor,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? (Color.lerp(baseColor, Colors.black, 0.20) ??
                                baseColor)
                          : (Color.lerp(
                                  baseColor,
                                  const Color(0xFFDCE2EC),
                                  0.30,
                                ) ??
                                baseColor),
                      boxShadow: AppShadows.dotIndicator(isDark: isDark),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: _colors.map((color) {
                return ColorCoin(
                  color: color,
                  onTap: () {
                    controller.updateSelectedHabitsColor(color);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tactile Neumorphic Color Coin
class ColorCoin extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const ColorCoin({super.key, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.65),
            width: 1.5,
          ),
          boxShadow: [
            ...AppShadows.bloom(
              color: color,
              isDark: isDark,
              blur: 6,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.60),
              offset: const Offset(-1.5, -1.5),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}
