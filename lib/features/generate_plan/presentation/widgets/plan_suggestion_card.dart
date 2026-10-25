import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/neumorphic_checkbox.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import '../../domain/entities/plan_suggestion.dart';
import 'neu_surface.dart';
import 'plan_tier_badge.dart';

/// Extruded habit card; selected cards glow softly in the category color while
/// unselected ones stay flat-raised so the choice reads through light alone.
class PlanSuggestionCard extends StatelessWidget {
  final PlanSuggestion suggestion;
  final Color color;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;

  const PlanSuggestionCard({
    super.key,
    required this.suggestion,
    required this.color,
    required this.onToggle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = suggestion.isSelected;

    return NeuSurface(
      onTap: onToggle,
      accentColor: color,
      highlighted: selected,
      borderRadius: AppRadius.lgRadius,
      padding: const EdgeInsets.all(16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: selected ? 1 : 0.6,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: NeumorphicCheckbox(
                value: selected,
                activeColor: color,
                onChanged: (_) => onToggle(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Octalysis habit tier badge + edit action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: PlanTierBadge(
                          tier: suggestion.tier,
                          dailyMinutes: suggestion.dailyMinutes,
                        ),
                      ),
                      if (onEdit != null)
                        NeumorphicIconButton.circle(
                          size: 32,
                          iconSize: 17,
                          icon: Icons.edit_note_rounded,
                          accentColor: color,
                          onPressed: onEdit!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    suggestion.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? color : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                      height: 1.4,
                    ),
                  ),

                  // ── CD3: "Why this fits you" – proof the answers shaped it
                  if (suggestion.personalReason.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InsightWell(
                      icon: Icons.person_pin_circle_rounded,
                      text: suggestion.personalReason,
                      color: color,
                    ),
                  ],

                  // ── CD2 + CD7: the next level to unlock ────────────────────
                  if (suggestion.levelUp.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InsightWell(
                      icon: Icons.trending_up_rounded,
                      text: suggestion.levelUp,
                      color: suggestion.tier.color,
                    ),
                  ],
                  const SizedBox(height: 12),
                  NeuChip(
                    icon: Icons.repeat_rounded,
                    label: suggestion.frequency,
                    color: selected ? color : Theme.of(context).hintColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Engraved well holding the personal reason and level-up hints.
class _InsightWell extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InsightWell({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeuSurface(
      depth: NeuDepth.inset,
      width: double.infinity,
      borderRadius: AppRadius.mdRadius,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.80),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
