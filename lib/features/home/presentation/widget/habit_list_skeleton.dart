import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/shimmer_effect.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';

/// Tactile Neumorphic placeholder card mimicking a loading [MyTextTaile].
class HabitTileSkeleton extends StatelessWidget {
  const HabitTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final placeholderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return SoftCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      borderRadius: AppRadius.card,
      child: ShimmerEffect(
        child: Row(
          children: [
            // Checkbox placeholder
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            const SizedBox(width: 16),
            // Title & subtitle placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 85,
                    height: 10,
                    decoration: BoxDecoration(
                      color: placeholderColor,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ),
            // Trailing action placeholder
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sliver list of [HabitTileSkeleton] items used during initial habit loading.
class SliverHabitListSkeleton extends StatelessWidget {
  final int itemCount;

  const SliverHabitListSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const HabitTileSkeleton(),
        childCount: itemCount,
      ),
    );
  }
}

/// Box ListView version of [HabitTileSkeleton] for tablet/desktop layouts.
class HabitListSkeleton extends StatelessWidget {
  final int itemCount;

  const HabitListSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => const HabitTileSkeleton(),
    );
  }
}
