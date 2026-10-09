import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/neumorphic_checkbox.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/core/theme/theme_utils.dart';
import '../../domain/entities/plan_suggestion.dart';

class PlanSuggestionCard extends StatelessWidget {
  final PlanSuggestion suggestion;
  final Color color;
  final VoidCallback onToggle;

  const PlanSuggestionCard({
    super.key,
    required this.suggestion,
    required this.color,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final selected = suggestion.isSelected;

    final surfaceGradientStart = ThemeUtils.surfaceGradientStart(baseColor, isDark);
    final surfaceGradientEnd = ThemeUtils.surfaceGradientEnd(baseColor, isDark);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                 surfaceGradientStart,
                 surfaceGradientEnd,
              ],
            ),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: isDark ? 0.65 : 0.45)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.85)),
              width: selected ? 1.5 : 1.0,
            ),
            boxShadow: selected
                ? AppShadows.selectedCard(primary: color, isDark: isDark)
                : AppShadows.tileResting(isDark: isDark),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Neumorphic Checkbox
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: NeumorphicCheckbox(
                  value: selected,
                  activeColor: color,
                  onChanged: (_) => onToggle(),
                ),
              ),

              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: selected ? color : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Frequency badge with Neumorphic badge shadow
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.70),
                        borderRadius: AppRadius.pillRadius,
                        border: Border.all(
                          color: selected
                              ? color.withValues(alpha: 0.3)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : const Color(0xFFA3B1C6).withValues(alpha: 0.3)),
                          width: 0.8,
                        ),
                        boxShadow: AppShadows.badge(isDark: isDark),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            size: 13,
                            color: selected ? color : theme.hintColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            suggestion.frequency,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected ? color : theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
