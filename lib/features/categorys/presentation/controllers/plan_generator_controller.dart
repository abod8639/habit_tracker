import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/plan_suggestion.dart';
import '../../data/datasources/questions_datasource.dart';

import 'package:habit_tracker/core/services/gemini_service.dart';
import '../../../home/presentation/controllers/habit_controller.dart';
import '../../../home/presentation/pages/home_screen.dart';
import 'package:habit_tracker/generated/l10n.dart';

enum PlanGeneratorStatus { idle, loading, success, error }

class PlanGeneratorController extends GetxController {
  final GeminiService _geminiService = GeminiService();

  // ── State ────────────────────────────────────────────────────────────────
  final Rx<PlanCategory?> selectedCategory = Rx<PlanCategory?>(null);
  final RxList<QuestionEntity> questions = <QuestionEntity>[].obs;
  final RxMap<String, dynamic> answers = <String, dynamic>{}.obs;
  final RxInt currentIndex = 0.obs;
  final RxList<PlanSuggestion> suggestions = <PlanSuggestion>[].obs;
  final Rx<PlanGeneratorStatus> status = PlanGeneratorStatus.idle.obs;
  final RxString errorMessage = ''.obs;

  // ── Computed ─────────────────────────────────────────────────────────────
  bool get isLastQuestion => currentIndex.value == questions.length - 1;
  bool get isFirstQuestion => currentIndex.value == 0;
  bool get isLoading => status.value == PlanGeneratorStatus.loading;
  bool get hasError => status.value == PlanGeneratorStatus.error;

  QuestionEntity? get currentQuestion =>
      questions.isNotEmpty ? questions[currentIndex.value] : null;

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex.value + 1) / questions.length;

  String get progressLabel => '${currentIndex.value + 1} / ${questions.length}';

  List<PlanSuggestion> get selectedSuggestions =>
      suggestions.where((s) => s.isSelected).toList();

  int get selectedCount => selectedSuggestions.length;

  bool get hasSelections => selectedCount > 0;

  // ── Category selection ────────────────────────────────────────────────────
  void selectCategory(PlanCategory category) {
    selectedCategory.value = category;
    questions.value = List<QuestionEntity>.from(
      QuestionsDataSource.forCategory(category),
    );
    answers.clear();
    currentIndex.value = 0;
    suggestions.value = <PlanSuggestion>[];
    status.value = PlanGeneratorStatus.idle;
    errorMessage.value = '';
  }

  // ── Answer management ─────────────────────────────────────────────────────
  void setAnswer(String questionId, dynamic value) {
    answers[questionId] = value;
    answers.refresh();
  }

  dynamic getAnswer(String questionId) => answers[questionId];

  /// For multipleChoice: toggles a single option in/out of the list
  void toggleMultipleChoiceOption(String questionId, String option) {
    final current = List<String>.from(answers[questionId] ?? []);
    if (current.contains(option)) {
      current.remove(option);
    } else {
      current.add(option);
    }
    setAnswer(questionId, current);
  }

  bool isOptionSelected(String questionId, String option) {
    final value = answers[questionId];
    if (value is List) return value.contains(option);
    if (value is String) return value == option;
    return false;
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _isCurrentAnswerValid() {
    final q = currentQuestion;
    if (q == null || !q.isRequired) return true;
    final answer = answers[q.id];
    if (answer == null) return false;
    if (answer is String && answer.trim().isEmpty) return false;
    if (answer is List && answer.isEmpty) return false;
    return true;
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void next() {
    if (!_isCurrentAnswerValid()) {
      Get.snackbar(
        S.current.answerRequired,
        S.current.pleaseAnswerToContinue,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (isLastQuestion) {
      generatePlan();
    } else {
      currentIndex.value++;
    }
  }

  void previous() {
    if (!isFirstQuestion) currentIndex.value--;
  }

  // ── AI plan generation ────────────────────────────────────────────────────
  Future<void> generatePlan() async {
    final category = selectedCategory.value;
    if (category == null) return;

    status.value = PlanGeneratorStatus.loading;

    try {
      final result = await _geminiService.generatePlan(
        category: category,
        userAnswers: answers.map((k, v) => MapEntry(k, v.toString())),
      );
      suggestions.value = result;

      status.value = PlanGeneratorStatus.success;
      Get.toNamed('/plan-result');
    } catch (e) {
      status.value = PlanGeneratorStatus.error;
      errorMessage.value = S.current.planGenerationFailed;
    }
  }

  // ── Suggestion selection ──────────────────────────────────────────────────
  void toggleSuggestion(int index) {
    suggestions[index].isSelected = !suggestions[index].isSelected;
    suggestions.refresh();
  }

  void selectAll() {
    for (var s in suggestions) {
      s.isSelected = true;
    }
    suggestions.refresh();
  }

  void deselectAll() {
    for (var s in suggestions) {
      s.isSelected = false;
    }
    suggestions.refresh();
  }

  // ── Saving habits ─────────────────────────────────────────────────────────
  Future<void> addSelectedHabits() async {
    if (!hasSelections) return;
    status.value = PlanGeneratorStatus.loading;

    try {
      final HabitController habitController =
          Get.isRegistered<HabitController>()
          ? Get.find<HabitController>()
          : Get.put(HabitController());

      final habitNames = selectedSuggestions.map((s) => s.name).toList();
      final bool success = await habitController.addMultipleHabits(habitNames);

      if (!success) {
        status.value = PlanGeneratorStatus.error;
        errorMessage.value = S.current.unexpectedError;
        return;
      }

      status.value = PlanGeneratorStatus.idle;
      final count = selectedCount;
      reset();

      Get.offAll(() => const HomeScreen());

      Get.snackbar(
        S.current.planActivatedTitle,
        S.current.planActivatedDesc(count),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
      );
    } catch (e, stack) {
      debugPrint('Error in addSelectedHabits: $e\n$stack');
      status.value = PlanGeneratorStatus.error;
      errorMessage.value = S.current.unexpectedError;
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────
  void reset() {
    selectedCategory.value = null;
    questions.value = <QuestionEntity>[];
    answers.clear();
    currentIndex.value = 0;
    suggestions.value = <PlanSuggestion>[];
    status.value = PlanGeneratorStatus.idle;
    errorMessage.value = '';
  }

  // ── Mock data (remove in production) ─────────────────────────────────────
  // List<PlanSuggestion> _mockSuggestions(PlanCategory category) {
  //   return [
  //     PlanSuggestion(
  //       name: 'Morning hydration ritual',
  //       description:
  //           'Drink 500ml of water immediately after waking up. Rehydrates your body after sleep and kickstarts metabolism.',
  //       frequency: 'daily',
  //       category: category.name,
  //     ),
  //     PlanSuggestion(
  //       name: 'Eat a protein-rich breakfast',
  //       description:
  //           'Include at least 20g of protein in your first meal. Reduces cravings and supports muscle retention.',
  //       frequency: 'daily',
  //       category: category.name,
  //     ),
  //     PlanSuggestion(
  //       name: 'No screen 30 min before bed',
  //       description:
  //           'Reduce blue light exposure before sleep to improve sleep quality and recovery.',
  //       frequency: 'daily',
  //       category: category.name,
  //     ),
  //     PlanSuggestion(
  //       name: 'Meal prep session',
  //       description:
  //           'Prepare healthy meals in advance. Eliminates last-minute unhealthy food decisions.',
  //       frequency: '2 times per week',
  //       category: category.name,
  //     ),
  //     PlanSuggestion(
  //       name: 'Track daily food intake',
  //       description:
  //           'Log everything you eat. Awareness is the first step to behavior change.',
  //       frequency: 'daily',
  //       category: category.name,
  //     ),
  //   ];
  // }
}
