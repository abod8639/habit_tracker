import 'package:flutter/material.dart';
import 'stats_neumorphic_utils.dart';

class HabitSubList extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final bool isCompleted;

  const HabitSubList({
    super.key,
    required this.habits,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color statusColor = isCompleted
        ? const Color(0xFF10B981) // Emerald
        : colorScheme.error;

    return Container(
      decoration: StatsNeumorphicTheme.wellDecoration(
        context,
        borderRadius: 18,
        accentColor: statusColor,
        accentAlpha: isDark ? 0.05 : 0.02,
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: habits.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          indent: 52,
          endIndent: 16,
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFA3B1C6).withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final habit = habits[index];
          final String name = habit['habit']?.toString() ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? statusColor.withValues(alpha: isDark ? 0.2 : 0.15)
                        : (isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.7)),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : const Color(0xFFA3B1C6).withValues(alpha: 0.2),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: isCompleted
                          ? FontWeight.normal
                          : FontWeight.w600,
                      color: isCompleted
                          ? colorScheme.onSurface.withValues(alpha: 0.55)
                          : colorScheme.onSurface,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: colorScheme.onSurface.withValues(
                        alpha: 0.45,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
