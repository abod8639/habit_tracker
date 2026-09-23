import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/core/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/features/ai_chat/presentation/controllers/ai_chat_binding.dart';
import 'package:habit_tracker/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import '../widget/fade_animation_summary_card.dart';
import '../widget/fade_animation_charts_section.dart';
import '../widget/fade_animation_trend_chart.dart';
import '../widget/fade_animation_habit_list_card.dart';

class HabitStatsPage extends StatefulWidget {
  const HabitStatsPage({super.key});

  @override
  State<HabitStatsPage> createState() => _HabitStatsPageState();
}

class _HabitStatsPageState extends State<HabitStatsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<HabitStatsController>()) {
        Get.find<HabitStatsController>().refreshStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) => keyboardShortCutsPages(event),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            S.current.ratepagetitle,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2.0,
        ),
        body: GetX<HabitStatsController>(
          builder: (controller) {
            if (controller.stats.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeAnimationSummaryCard(
                      animationController: _animationController,
                    ),
                    const SizedBox(height: 20),
                    FadeAnimationChartsSection(
                      animationController: _animationController,
                    ),
                    const SizedBox(height: 20),
                    FadeAnimationTrendChart(
                      animationController: _animationController,
                    ),
                    const SizedBox(height: 20),
                    FadeAnimationHabitListCard(
                      animationController: _animationController,
                    ),
                    const SizedBox(height: 80), // extra padding for FAB
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'ai_coach',
          onPressed: () {
            Get.to(
              () => const AiChatPage(),
              binding: AiChatBinding(),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: Text(S.current.aiCoach),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
