import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/plan_suggestion.dart';
import 'package:habit_tracker/core/components/neu_surface.dart';

class PlanActivationCelebrationDialog extends StatelessWidget {
  final PlanCategory? category;
  final List<PlanSuggestion> activatedHabits;
  final int totalDailyMinutes;
  final PlanSuggestion? firstWinHabit;
  final VoidCallback onContinue;

  const PlanActivationCelebrationDialog({
    super.key,
    required this.category,
    required this.activatedHabits,
    required this.totalDailyMinutes,
    this.firstWinHabit,
    required this.onContinue,
  });

  void _shareAccountability(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final categoryName = category?.displayName ?? '';

    final habitBullets = activatedHabits.map((h) => '• ${h.name}').join('\n');

    final shareText = isArabic
        ? '''🔥 بدأت للتو مسار "$categoryName" في متتبع العادات بهندسة سلوكية!
عاداتي اليومية الجديدة:
$habitBullets

⏱️ $totalDailyMinutes دقيقة فقط يومياً.
هل تتابع التزامي أو تشاركني التحدي؟ 🤝'''
        : '''🔥 I just launched my "$categoryName" quest on Habit Tracker!
My daily blueprint:
$habitBullets

⏱️ Just $totalDailyMinutes min a day.
Will you check in on me or join me? 🤝''';

    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isArabic
                    ? 'تم نسخ رسالة المساءلة للمشاركة مع أصدقائك!'
                    : 'Accountability blueprint copied to clipboard!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final color = category?.color ?? colorScheme.primary;
    final ignition = HabitTier.ignition;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: NeuSurface(
        borderRadius: AppRadius.dialogRadius,
        accentColor: color,
        highlighted: true,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Glowing extruded trophy orb ─────────────────────────────
              NeuOrb(
                size: 84,
                emoji: category?.badgeEmoji ?? '🏆',
                color: color,
                glow: true,
              ),
              const SizedBox(height: 22),

              // ── Win State Header ──────────────────────────────────────────
              Text(
                isArabic
                    ? 'انطلقت رحلتك التحولية! 🎉'
                    : 'Your Journey Has Begun! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'تمت إضافة ${activatedHabits.length} عادات مصممة لك إلى متتبعك اليومي.'
                    : '${activatedHabits.length} habits designed for you were added to your tracker.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.70),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // ── CD2: a real first win, right now (engraved well) ──────────
              if (firstWinHabit != null)
                NeuSurface(
                  depth: NeuDepth.inset,
                  width: double.infinity,
                  borderRadius: AppRadius.mdRadius,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(ignition.icon, color: ignition.color, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isArabic
                                  ? 'فوزك الأول اليوم (أقل من دقيقتين):'
                                  : 'Your first win today (under 2 min):',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ignition.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        firstWinHabit!.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'أنجزها الآن وسجّلها لتبدأ سلسلتك من اليوم الأول.'
                            : 'Do it now and check it off to start your streak on day one.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colorScheme.onSurface.withValues(alpha: 0.70),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),

              // ── Social Accountability Share (CD5: Social Influence) ───────
              NeumorphicButton(
                text: isArabic
                    ? 'شارك خطتك مع صديق للمساءلة'
                    : 'Share with an accountability buddy',
                icon: Icons.share_rounded,
                isPrimary: false,
                accentColor: color,
                onPressed: () => _shareAccountability(context),
                width: double.infinity,
                height: 46,
              ),
              const SizedBox(height: 14),

              // ── Continue to Tracker Action Button ─────────────────────────
              NeumorphicButton(
                text: isArabic
                    ? 'انطلق إلى لوحة عاداتك 🚀'
                    : 'Go to Your Habit Tracker 🚀',
                accentColor: color,
                onPressed: onContinue,
                width: double.infinity,
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
