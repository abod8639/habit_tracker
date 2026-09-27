import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A reusable Neumorphic Pill Segmented Toggle for switching views, filters, or modes.
/// Uses centralized design tokens from [AppRadius] and [AppShadows].
class NeumorphicPillToggle extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<IconData>? icons;

  const NeumorphicPillToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = theme.cardColor;
    final wellBase = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.22) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.30) ?? baseColor);

    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: wellBase,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.70),
          width: 1.0,
        ),
        boxShadow: AppShadows.wellDual(isDark: isDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          final hasIcon = icons != null && index < icons!.length;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.well),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          colorScheme.primary,
                          Color.lerp(colorScheme.primary, Colors.black, isDark ? 0.15 : 0.08) ??
                              colorScheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.transparent,
                boxShadow: isSelected
                    ? AppShadows.bloom(
                        color: colorScheme.primary,
                        isDark: isDark,
                        blur: 8.0,
                        spread: 0.5,
                        offset: const Offset(0, 2),
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasIcon) ...[
                    Icon(
                      icons![index],
                      size: 15,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
