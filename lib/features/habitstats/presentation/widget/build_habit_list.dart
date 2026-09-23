import 'package:flutter/material.dart';

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

    final statusColor =
        isCompleted ? colorScheme.primary : colorScheme.secondary;

    return Container(
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
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
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
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
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isCompleted ? FontWeight.normal : FontWeight.w600,
                      color: isCompleted
                          ? colorScheme.onSurface.withValues(alpha: 0.7)
                          : colorScheme.onSurface,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor:
                          colorScheme.onSurface.withValues(alpha: 0.5),
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

Widget buildHabitList(
  BuildContext context,
  List<Map<String, dynamic>> habits,
  bool isCompleted,
) {
  return HabitSubList(
    habits: habits,
    isCompleted: isCompleted,
  );
}

