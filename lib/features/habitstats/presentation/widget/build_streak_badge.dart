import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';

Widget buildStreakBadge(int streak) {
  return Builder(
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withAlpha(40),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department,
              color: Theme.of(context).colorScheme.secondary,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              S.of(context).streakDay(streak),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      );
    },
  );
}
