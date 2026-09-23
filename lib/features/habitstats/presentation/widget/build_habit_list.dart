import 'package:flutter/material.dart';

Widget buildHabitList(
  BuildContext context,
  List<Map<String, dynamic>> habits,
  bool isCompleted,
) {
  return Container(
    decoration: BoxDecoration(
      color: isCompleted
          ? Colors.green.withValues(alpha: 0.05)
          : Colors.orange.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: habits.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
      itemBuilder: (context, index) {
        final habit = habits[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: CircleAvatar(
            backgroundColor: isCompleted ? Colors.green : Colors.orange,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            habit['habit'],
            style: TextStyle(
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.orange,
          ),
        );
      },
    ),
  );
}
