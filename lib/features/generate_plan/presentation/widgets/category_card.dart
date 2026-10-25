import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import '../../domain/entities/category_entity.dart';
import 'neu_surface.dart';

/// Extruded category tile featuring a prominent centered hero icon,
/// an archetype identity badge, and balanced Neumorphic tactile styling.
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final color = category.color;
    final isArabic = Intl.getCurrentLocale().startsWith('ar');

    return NeuSurface(
      onTap: onTap,
      accentColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Top: Engraved archetype identity pill ──────────────────────
          NeuChip(
            emoji: category.badgeEmoji,
            label: category.archetypeTitle,
            color: color,
            fontSize: 9.5,
          ),

          const SizedBox(height: 10),

          // ── Center: Hero Neumorphic Orb with ambient glow halo ─────────
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: isDark ? 0.28 : 0.14),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              NeuOrb(
                size: 48,
                icon: category.icon,
                color: color,
                glow: true,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Category Title ─────────────────────────────────────────────
          Text(
            category.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),

          // ── Quest Tagline ──────────────────────────────────────────────
          Text(
            category.questTagline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.25,
            ),
          ),

          const Spacer(),

          // ── Bottom: Question count & time estimate badge ───────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              borderRadius: AppRadius.pillRadius,
              color: color.withValues(alpha: isDark ? 0.14 : 0.08),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 11,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  isArabic
                      ? '$questionCount أسئلة • دقيقة'
                      : '$questionCount questions • ~1m',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

