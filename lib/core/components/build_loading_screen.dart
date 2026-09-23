import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';

Widget buildLoadingScreen() {
  return Builder(
    builder: (context) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).loadingHabits,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).justAMoment,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    },
  );
}
