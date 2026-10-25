import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/core/components/neumorphic_progress_bar.dart';
import '../../domain/entities/category_entity.dart';
import 'package:habit_tracker/core/components/neu_surface.dart';

class OctalysisGenerationLoader extends StatefulWidget {
  final PlanCategory? category;

  const OctalysisGenerationLoader({
    super.key,
    this.category,
  });

  @override
  State<OctalysisGenerationLoader> createState() =>
      _OctalysisGenerationLoaderState();
}

class _OctalysisGenerationLoaderState extends State<OctalysisGenerationLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  Timer? _stepTimer;
  int _currentStepIndex = 0;

  List<String> _getSteps(bool isArabic) {
    if (isArabic) {
      return const [
        'نقرأ إجاباتك ومستواك الحالي...',
        'نوزع العادات على الوقت المتاح لك...',
        'نصمم عادة تتجاوز العقبة التي ذكرتها...',
        'نربط كل عادة بلحظة ثابتة في يومك...',
      ];
    }
    return const [
      'Reading your answers and current level...',
      'Fitting habits into the time you have...',
      'Designing a habit to beat your biggest obstacle...',
      'Anchoring each habit to a moment in your day...',
    ];
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _stepTimer = Timer.periodic(const Duration(milliseconds: 2200), (timer) {
      if (mounted) {
        final isArabic = Intl.getCurrentLocale().startsWith('ar');
        final steps = _getSteps(isArabic);
        if (_currentStepIndex < steps.length - 1) {
          setState(() {
            _currentStepIndex++;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = Intl.getCurrentLocale().startsWith('ar');
    final color = widget.category?.color ?? colorScheme.primary;
    final steps = _getSteps(isArabic);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Breathing extruded orb with an engraved progress well ──────
            ScaleTransition(
              scale: _scaleAnimation,
              child: NeuSurface(
                shape: BoxShape.circle,
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(16),
                accentColor: color,
                highlighted: true,
                child: NeuSurface(
                  shape: BoxShape.circle,
                  depth: NeuDepth.inset,
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      Icon(
                        widget.category?.icon ?? Icons.auto_awesome_rounded,
                        size: 30,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),

            NeuChip(
              emoji: '✨',
              label: isArabic ? 'نصمم خطتك الشخصية' : 'Designing your plan',
              color: color,
              fontSize: 11.5,
            ),
            const SizedBox(height: 18),

            // ── Dynamic Sequential Step Text (Labor Illusion) ───────────────
            SizedBox(
              height: 52,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  ),
                ),
                child: Text(
                  steps[_currentStepIndex],
                  key: ValueKey(_currentStepIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Engraved step progress (CD2: visible progress) ─────────────
            SizedBox(
              width: 200,
              child: NeumorphicProgressBar(
                value: (_currentStepIndex + 1) / steps.length,
                accentColor: color,
                height: 8,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              isArabic
                  ? 'نصمم عادات صغيرة تمنحك أول إنجاز اليوم 🚀'
                  : 'Designing small habits for your first win today 🚀',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: colorScheme.onSurface.withValues(alpha: 0.60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
