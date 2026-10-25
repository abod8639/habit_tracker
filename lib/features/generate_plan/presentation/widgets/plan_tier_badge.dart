import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/plan_suggestion.dart';
import 'neu_surface.dart';

/// Engraved tier pill with the habit's daily time cost.
class PlanTierBadge extends StatelessWidget {
  final HabitTier tier;
  final int dailyMinutes;

  const PlanTierBadge({super.key, required this.tier, this.dailyMinutes = 0});

  @override
  Widget build(BuildContext context) {
    final isArabic = Intl.getCurrentLocale().startsWith('ar');
    return NeuChip(
      icon: tier.icon,
      label: tier.label,
      color: tier.color,
      fontSize: 10.5,
      trailing: dailyMinutes > 0
          ? Text(
              isArabic ? '• $dailyMinutes د' : '• $dailyMinutes min',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: tier.color,
              ),
            )
          : null,
    );
  }
}
