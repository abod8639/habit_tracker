import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/core/theme/theme_utils.dart';
import '../../domain/entities/category_entity.dart';

class CategoryCard extends StatefulWidget {
  final PlanCategory category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final color = widget.category.color;

    final surfaceGradientStart = ThemeUtils.surfaceGradientStart(baseColor, isDark);
    final surfaceGradientEnd = ThemeUtils.surfaceGradientEnd(baseColor, isDark);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    color.withValues(alpha: isDark ? 0.08 : 0.06),
                    surfaceGradientStart,
                  ),
                  Color.alphaBlend(
                    color.withValues(alpha: isDark ? 0.12 : 0.08),
                    surfaceGradientEnd,
                  ),
                ],
              ),
              border: Border.all(
                color: isDark
                    ? color.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: _isPressed
                  ? AppShadows.softButtonPressed(isDark: isDark)
                  : [
                      ...AppShadows.softCard(isDark: isDark),
                      ...AppShadows.bloom(
                        color: color,
                        isDark: isDark,
                        blur: 8,
                        spread: 0.3,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Embossed Neumorphic icon bubble
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.lgRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(color, Colors.white, isDark ? 0.08 : 0.20) ?? color,
                        Color.lerp(color, Colors.black, isDark ? 0.15 : 0.08) ?? color,
                      ],
                    ),
                    boxShadow: AppShadows.bloom(
                      color: color,
                      isDark: isDark,
                      blur: 7,
                      spread: 0.5,
                      offset: const Offset(0, 2),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.category.icon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.category.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
