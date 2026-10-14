import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/core/utils/number_utils.dart';
import 'package:habit_tracker/features/generate_plan/data/datasources/plan_remote_datasource.dart';
import 'package:habit_tracker/features/generate_plan/data/repositories/plan_repository_impl.dart';
import 'package:habit_tracker/features/generate_plan/domain/entities/category_entity.dart';
import 'package:habit_tracker/features/generate_plan/domain/entities/plan_suggestion.dart';
import 'package:habit_tracker/features/generate_plan/domain/entities/question_entity.dart';
import 'package:habit_tracker/features/generate_plan/domain/repositories/plan_repository.dart';
import 'package:habit_tracker/features/generate_plan/domain/usecases/generate_plan_usecase.dart';
import 'package:habit_tracker/features/generate_plan/domain/usecases/get_questions_usecase.dart';
import 'package:habit_tracker/features/generate_plan/domain/usecases/save_plan_habits_usecase.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/generated/l10n.dart';

// Data Sources
final planRemoteDataSourceProvider = Provider<PlanRemoteDataSource>((ref) {
  final gemini = ref.watch(geminiServiceProvider);
  return PlanRemoteDataSourceImpl(geminiService: gemini);
});

// Repository
final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final remote = ref.watch(planRemoteDataSourceProvider);
  final habitRepo = ref.watch(habitRepositoryProvider);
  return PlanRepositoryImpl(
    remoteDataSource: remote,
    habitRepository: habitRepo,
  );
});

// Use Cases
final getQuestionsUseCaseProvider = Provider<GetQuestionsUseCase>((ref) {
  return GetQuestionsUseCase(ref.watch(planRepositoryProvider));
});

final generatePlanUseCaseProvider = Provider<GeneratePlanUseCase>((ref) {
  return GeneratePlanUseCase(ref.watch(planRepositoryProvider));
});

final savePlanHabitsUseCaseProvider = Provider<SavePlanHabitsUseCase>((ref) {
  return SavePlanHabitsUseCase(ref.watch(planRepositoryProvider));
});

// State
enum PlanGeneratorStatus { idle, loading, success, error }

class PlanGeneratorState {
  final PlanCategory? selectedCategory;
  final List<QuestionEntity> questions;
  final Map<String, dynamic> answers;
  final int currentIndex;
  final List<PlanSuggestion> suggestions;
  final PlanGeneratorStatus status;
  final String errorMessage;

  const PlanGeneratorState({
    this.selectedCategory,
    this.questions = const [],
    this.answers = const {},
    this.currentIndex = 0,
    this.suggestions = const [],
    this.status = PlanGeneratorStatus.idle,
    this.errorMessage = '',
  });

  bool get isLastQuestion =>
      questions.isNotEmpty && currentIndex == questions.length - 1;
  bool get isFirstQuestion => currentIndex == 0;
  bool get isLoading => status == PlanGeneratorStatus.loading;
  bool get hasError => status == PlanGeneratorStatus.error;

  QuestionEntity? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  String get progressLabel =>
      '${currentIndex + 1} / ${questions.length}';

  List<PlanSuggestion> get selectedSuggestions =>
      suggestions.where((s) => s.isSelected).toList();

  int get selectedCount => selectedSuggestions.length;
  bool get hasSelections => selectedCount > 0;

  bool isOptionSelected(String questionId, String option) {
    final value = answers[questionId];
    if (value is List) return value.contains(option);
    if (value is String) return value == option;
    return false;
  }

  dynamic getAnswer(String questionId) => answers[questionId];

  PlanGeneratorState copyWith({
    PlanCategory? selectedCategory,
    bool clearCategory = false,
    List<QuestionEntity>? questions,
    Map<String, dynamic>? answers,
    int? currentIndex,
    List<PlanSuggestion>? suggestions,
    PlanGeneratorStatus? status,
    String? errorMessage,
  }) {
    return PlanGeneratorState(
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
      suggestions: suggestions ?? this.suggestions,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier
class PlanGeneratorNotifier extends Notifier<PlanGeneratorState> {
  @override
  PlanGeneratorState build() {
    return const PlanGeneratorState();
  }

  GetQuestionsUseCase get _getQuestionsUseCase =>
      ref.read(getQuestionsUseCaseProvider);
  GeneratePlanUseCase get _generatePlanUseCase =>
      ref.read(generatePlanUseCaseProvider);
  SavePlanHabitsUseCase get _savePlanHabitsUseCase =>
      ref.read(savePlanHabitsUseCaseProvider);

  void selectCategory(PlanCategory category) {
    final questions = _getQuestionsUseCase(category);
    state = PlanGeneratorState(
      selectedCategory: category,
      questions: List<QuestionEntity>.from(questions),
      answers: {},
      currentIndex: 0,
      suggestions: [],
      status: PlanGeneratorStatus.idle,
      errorMessage: '',
    );
  }

  void setAnswer(String questionId, dynamic value) {
    final nextAnswers = Map<String, dynamic>.from(state.answers);
    nextAnswers[questionId] = value;
    state = state.copyWith(answers: nextAnswers);
  }

  void toggleMultipleChoiceOption(String questionId, String option) {
    final current = List<String>.from(state.answers[questionId] ?? []);
    if (current.contains(option)) {
      current.remove(option);
    } else {
      current.add(option);
    }
    setAnswer(questionId, current);
  }

  String? validateCurrentAnswer({required bool isArabic}) {
    final q = state.currentQuestion;
    if (q == null) return null;
    final answer = state.answers[q.id];
    if (q.isRequired) {
      if (answer == null) return S.current.pleaseAnswerToContinue;
      if (answer is String && answer.trim().isEmpty) {
        return S.current.pleaseAnswerToContinue;
      }
      if (answer is List && answer.isEmpty) {
        return S.current.pleaseAnswerToContinue;
      }
    }
    if (answer != null && q.isNumeric) {
      final rawStr = answer.toString().trim();
      if (rawStr.isNotEmpty) {
        final parsed = tryParseNormalizedNum(rawStr);
        if (parsed == null) {
          return isArabic
              ? 'يرجى إدخال رقم صحيح'
              : 'Please enter a valid number';
        }
        if (q.maxValue != null && parsed > q.maxValue!) {
          return isArabic
              ? 'الحد الأقصى المسموح به هو ${q.maxValue}'
              : 'Maximum allowed value is ${q.maxValue}';
        }
        if (q.minValue != null && parsed < q.minValue!) {
          return isArabic
              ? 'الحد الأدنى المسموح به هو ${q.minValue}'
              : 'Minimum allowed value is ${q.minValue}';
        }
        setAnswer(q.id, parsed);
      }
    }
    return null;
  }

  void next() {
    if (!state.isLastQuestion) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previous() {
    if (!state.isFirstQuestion) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  Future<bool> generatePlan() async {
    final category = state.selectedCategory;
    if (category == null) return false;

    state = state.copyWith(
      status: PlanGeneratorStatus.loading,
      errorMessage: '',
    );

    final result = await _generatePlanUseCase(
      category: category,
      userAnswers: state.answers,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PlanGeneratorStatus.error,
          errorMessage: failure.message.isNotEmpty
              ? failure.message
              : S.current.planGenerationFailed,
        );
        return false;
      },
      (suggestions) {
        state = state.copyWith(
          suggestions: suggestions,
          status: PlanGeneratorStatus.success,
        );
        return true;
      },
    );
  }

  void toggleSuggestion(int index) {
    if (index < 0 || index >= state.suggestions.length) return;
    final updated = List<PlanSuggestion>.from(state.suggestions);
    updated[index].isSelected = !updated[index].isSelected;
    state = state.copyWith(suggestions: updated);
  }

  void selectAll() {
    final updated = List<PlanSuggestion>.from(state.suggestions);
    for (var s in updated) {
      s.isSelected = true;
    }
    state = state.copyWith(suggestions: updated);
  }

  void deselectAll() {
    final updated = List<PlanSuggestion>.from(state.suggestions);
    for (var s in updated) {
      s.isSelected = false;
    }
    state = state.copyWith(suggestions: updated);
  }

  Future<int?> addSelectedHabits() async {
    if (!state.hasSelections) return null;
    state = state.copyWith(status: PlanGeneratorStatus.loading);

    try {
      final habitNames = state.selectedSuggestions.map((s) => s.name).toList();
      final result = await _savePlanHabitsUseCase(habitNames);

      return await result.fold(
        (failure) async {
          state = state.copyWith(
            status: PlanGeneratorStatus.error,
            errorMessage: failure.message.isNotEmpty
                ? failure.message
                : S.current.unexpectedError,
          );
          return null;
        },
        (_) async {
          await ref.read(habitNotifierProvider.notifier).refreshData();
          final count = state.selectedCount;
          reset();
          return count;
        },
      );
    } catch (e, stack) {
      debugPrint('Error in addSelectedHabits: $e\n$stack');
      state = state.copyWith(
        status: PlanGeneratorStatus.error,
        errorMessage: S.current.unexpectedError,
      );
      return null;
    }
  }

  void reset() {
    state = const PlanGeneratorState();
  }
}

final planGeneratorNotifierProvider =
    NotifierProvider<PlanGeneratorNotifier, PlanGeneratorState>(() {
  return PlanGeneratorNotifier();
});
