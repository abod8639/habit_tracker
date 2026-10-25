import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/category_entity.dart';
import 'neu_surface.dart';

/// Extruded category tile that presses into the surface when tapped.
class CategoryCard extends StatelessWidget {
  final PlanCategory category;
  final int questionCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.questionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = category.color;
    final isArabic = Intl.getCurrentLocale().startsWith('ar');

    return NeuSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: extruded icon orb + engraved archetype tag (CD1 identity)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeuOrb(size: 46, icon: category.icon, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: NeuChip(
                  emoji: category.badgeEmoji,
                  label: category.archetypeTitle,
                  color: color,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            category.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            category.questTagline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 12,
                color: color.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  isArabic
                      ? '$questionCount أسئلة • دقيقة تقريباً'
                      : '$questionCount questions • ~1 min',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
