import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/routes/app_router.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../../../home/presentation/controllers/habit_controller.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/plan_suggestion.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/usecases/generate_plan_usecase.dart';
import '../../domain/usecases/get_questions_usecase.dart';
import '../../domain/usecases/save_plan_habits_usecase.dart';

enum PlanGeneratorStatus { idle, loading, success, error }

class PlanGeneratorController extends GetxController {
  final GetQuestionsUseCase _getQuestionsUseCase;
  final GeneratePlanUseCase _generatePlanUseCase;
  final SavePlanHabitsUseCase _savePlanHabitsUseCase;

  PlanGeneratorController({
    GetQuestionsUseCase? getQuestionsUseCase,
    GeneratePlanUseCase? generatePlanUseCase,
    SavePlanHabitsUseCase? savePlanHabitsUseCase,
  })  : _getQuestionsUseCase =
            getQuestionsUseCase ?? Get.find<GetQuestionsUseCase>(),
        _generatePlanUseCase =
            generatePlanUseCase ?? Get.find<GeneratePlanUseCase>(),
        _savePlanHabitsUseCase =
            savePlanHabitsUseCase ?? Get.find<SavePlanHabitsUseCase>();

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
      _getQuestionsUseCase(category),
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

    final result = await _generatePlanUseCase(
      category: category,
      userAnswers: answers,
    );

    result.fold(
      (failure) {
        status.value = PlanGeneratorStatus.error;
        errorMessage.value = failure.message.isNotEmpty
            ? failure.message
            : S.current.planGenerationFailed;
      },
      (generatedSuggestions) {
        suggestions.value = generatedSuggestions;
        status.value = PlanGeneratorStatus.success;
        AppRouter.router.push(AppRoutes.result);
      },
    );
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
      final habitNames = selectedSuggestions.map((s) => s.name).toList();
      final result = await _savePlanHabitsUseCase(habitNames);

      result.fold(
        (failure) {
          status.value = PlanGeneratorStatus.error;
          errorMessage.value = failure.message.isNotEmpty
              ? failure.message
              : S.current.unexpectedError;
        },
        (_) async {
          // If HabitController is loaded, notify it to refresh
          if (Get.isRegistered<HabitController>()) {
            await Get.find<HabitController>().refreshData();
          }

          status.value = PlanGeneratorStatus.idle;
          final count = selectedCount;
          reset();

          AppRouter.router.go(AppRoutes.home);

          Get.snackbar(
            S.current.planActivatedTitle,
            S.current.planActivatedDesc(count),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: const Color(0xFFFFFFFF),
            duration: const Duration(seconds: 3),
          );
        },
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
}
