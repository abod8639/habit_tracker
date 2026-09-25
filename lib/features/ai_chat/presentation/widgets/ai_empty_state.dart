import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'ai_avatar.dart';

/// Neumorphic empty state with greeting card and interactive starter suggestions.
class AiEmptyState extends StatelessWidget {
  final Function(String prompt) onPromptSelected;

  const AiEmptyState({
    super.key,
    required this.onPromptSelected,
  });

  List<String> _getSuggestions() {
    final isArabic = Get.locale?.languageCode == 'ar';
    if (isArabic) {
      return const [
        '⚡ كيف أحافظ على استمرارية عاداتي؟',
        '🎯 ساعدني في ترتيب أولويات اليوم',
        '💪 أحتاج جرعة تحفيز سريعة',
        '🧠 كيف أتغلب على التسويف والمماطلة؟',
      ];
    }
    return const [
      '⚡ How do I stay consistent with my habits?',
      '🎯 Help me organize today\'s priorities',
      '💪 I need a quick motivation boost',
      '🧠 How do I overcome procrastination?',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;
    final suggestions = _getSuggestions();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Soft Neumorphic Hero Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.035)
                        : Colors.white.withValues(alpha: 0.9),
                    offset: const Offset(-4, -4),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.45)
                        : const Color(0xFFA3B1C6).withValues(alpha: 0.32),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const AiAvatar(size: 76),
                  const SizedBox(height: 20),
                  Text(
                    S.current.aiCoach,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    S.current.aiGreeting,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Starter Suggestions Title
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 6, bottom: 12),
                child: Text(
                  Get.locale?.languageCode == 'ar'
                      ? 'اقتراحات للبدء:'
                      : 'Suggested prompts:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

            // Suggestion Chips
            ...suggestions.map(
              (prompt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SuggestionChip(
                  text: prompt,
                  onTap: () => onPromptSelected(prompt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.text,
    required this.onTap,
  });

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    if (mounted) {
      await _controller.reverse();
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.025)
                    : Colors.white.withValues(alpha: 0.8),
                offset: const Offset(-2, -2),
                blurRadius: 4,
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : const Color(0xFFA3B1C6).withValues(alpha: 0.25),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
