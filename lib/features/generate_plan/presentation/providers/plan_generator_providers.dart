import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/contracts/habit_facade_contract.dart';
import 'package:habit_tracker/core/error/failures.dart';
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
import 'package:habit_tracker/generated/l10n.dart';

// Data Sources
final planRemoteDataSourceProvider = Provider<PlanRemoteDataSource>((ref) {
  final gemini = ref.watch(geminiServiceProvider);
  return PlanRemoteDataSourceImpl(geminiService: gemini);
});

// Repository
final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final remote = ref.watch(planRemoteDataSourceProvider);
  final habitFacade = ref.watch(habitFacadeProvider);
  return PlanRepositoryImpl(
    remoteDataSource: remote,
    habitFacade: habitFacade,
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
  final Failure? activeFailure;

  const PlanGeneratorState({
    this.selectedCategory,
    this.questions = const [],
    this.answers = const {},
    this.currentIndex = 0,
    this.suggestions = const [],
    this.status = PlanGeneratorStatus.idle,
    this.errorMessage = '',
    this.activeFailure,
  });

  bool get isLastQuestion =>
      questions.isNotEmpty && currentIndex == questions.length - 1;
  bool get isFirstQuestion => currentIndex == 0;
  bool get isLoading => status == PlanGeneratorStatus.loading;
  bool get hasError =>
      status == PlanGeneratorStatus.error || activeFailure != null;

  QuestionEntity? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
      ? questions[currentIndex]
      : null;

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  String get progressLabel => '${currentIndex + 1} / ${questions.length}';

  List<PlanSuggestion> get selectedSuggestions =>
      suggestions.where((s) => s.isSelected).toList();

  int get selectedCount => selectedSuggestions.length;
  bool get hasSelections => selectedCount > 0;

  /// Honest daily time commitment of the selected habits (replaces fake XP:
  /// Octalysis warns that points with no real use erode trust).
  int get totalDailyMinutes =>
      selectedSuggestions.fold<int>(0, (sum, s) => sum + s.dailyMinutes);

  /// The tiny starter habit the user should do right now to bank a day-one win.
  PlanSuggestion? get firstWinHabit {
    for (final s in selectedSuggestions) {
      if (s.tier == HabitTier.ignition) return s;
    }
    return selectedSuggestions.isEmpty ? null : selectedSuggestions.first;
  }

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
    Failure? activeFailure,
    bool clearFailure = false,
  }) {
    return PlanGeneratorState(
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
      suggestions: suggestions ?? this.suggestions,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      activeFailure: clearFailure
          ? null
          : (activeFailure ?? this.activeFailure),
    );
  }
}

// Notifier
class PlanGeneratorNotifier extends AsyncNotifier<PlanGeneratorState> {
  bool _isDisposed = false;

  @override
  FutureOr<PlanGeneratorState> build() {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
    });
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
    state = AsyncValue.data(
      PlanGeneratorState(
        selectedCategory: category,
        questions: List<QuestionEntity>.from(questions),
        answers: const {},
        currentIndex: 0,
        suggestions: const [],
        status: PlanGeneratorStatus.idle,
        errorMessage: '',
        activeFailure: null,
      ),
    );
  }

  void setAnswer(String questionId, dynamic value) {
    final current = state.value ?? const PlanGeneratorState();
    final nextAnswers = Map<String, dynamic>.from(current.answers);
    nextAnswers[questionId] = value;
    state = AsyncValue.data(current.copyWith(answers: nextAnswers));
  }

  void toggleMultipleChoiceOption(String questionId, String option) {
    final current = state.value ?? const PlanGeneratorState();
    final nextAnswers = Map<String, dynamic>.from(current.answers);
    final selectedList = List<String>.from(nextAnswers[questionId] ?? []);
    if (selectedList.contains(option)) {
      selectedList.remove(option);
    } else {
      selectedList.add(option);
    }
    nextAnswers[questionId] = selectedList;
    state = AsyncValue.data(current.copyWith(answers: nextAnswers));
  }

  String? validateCurrentAnswer({required bool isArabic}) {
    final current = state.value;
    if (current == null) return null;
    final q = current.currentQuestion;
    if (q == null) return null;
    final answer = current.answers[q.id];
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
    final current = state.value ?? const PlanGeneratorState();
    if (!current.isLastQuestion) {
      state = AsyncValue.data(
        current.copyWith(currentIndex: current.currentIndex + 1),
      );
    }
  }

  void previous() {
    final current = state.value ?? const PlanGeneratorState();
    if (!current.isFirstQuestion) {
      state = AsyncValue.data(
        current.copyWith(currentIndex: current.currentIndex - 1),
      );
    }
  }

  Future<bool> generatePlan() async {
    final current = state.value ?? const PlanGeneratorState();
    final category = current.selectedCategory;
    if (category == null) return false;

    state = AsyncValue.data(
      current.copyWith(
        status: PlanGeneratorStatus.loading,
        clearFailure: true,
      ),
    );

    final result = await _generatePlanUseCase(
      category: category,
      userAnswers: current.answers,
    );

    if (_isDisposed) return false;

    return result.fold(
      (failure) {
        final errorMsg = failure.toMessage();
        state = AsyncValue.data(
          current.copyWith(
            status: PlanGeneratorStatus.error,
            errorMessage: errorMsg,
            activeFailure: failure,
          ),
        );
        return false;
      },
      (suggestions) {
        state = AsyncValue.data(
          current.copyWith(
            suggestions: suggestions,
            status: PlanGeneratorStatus.success,
            errorMessage: '',
            clearFailure: true,
          ),
        );
        return true;
      },
    );
  }

  /// Re-rolls the plan from the same answers. Previous suggestions are restored
  /// if generation fails so the user never loses a plan they liked.
  Future<bool> regeneratePlan() async {
    final previous = state.value ?? const PlanGeneratorState();
    if (previous.selectedCategory == null) return false;
    state = AsyncValue.data(previous.copyWith(suggestions: const []));
    final success = await generatePlan();
    if (!success && !_isDisposed) {
      final failed = state.value ?? previous;
      state = AsyncValue.data(
        failed.copyWith(suggestions: previous.suggestions),
      );
    }
    return success;
  }

  void toggleSuggestion(int index) {
    final current = state.value ?? const PlanGeneratorState();
    if (index < 0 || index >= current.suggestions.length) return;
    final updated = List<PlanSuggestion>.from(current.suggestions);
    updated[index].isSelected = !updated[index].isSelected;
    state = AsyncValue.data(current.copyWith(suggestions: updated));
  }

  void selectAll() {
    final current = state.value ?? const PlanGeneratorState();
    final updated = List<PlanSuggestion>.from(current.suggestions);
    for (var s in updated) {
      s.isSelected = true;
    }
    state = AsyncValue.data(current.copyWith(suggestions: updated));
  }

  void deselectAll() {
    final current = state.value ?? const PlanGeneratorState();
    final updated = List<PlanSuggestion>.from(current.suggestions);
    for (var s in updated) {
      s.isSelected = false;
    }
    state = AsyncValue.data(current.copyWith(suggestions: updated));
  }

  void updateSuggestion(
    int index, {
    String? name,
    String? description,
    String? frequency,
  }) {
    final current = state.value ?? const PlanGeneratorState();
    if (index < 0 || index >= current.suggestions.length) return;
    final updated = List<PlanSuggestion>.from(current.suggestions);
    updated[index] = updated[index].copyWith(
      name: name,
      description: description,
      frequency: frequency,
    );
    state = AsyncValue.data(current.copyWith(suggestions: updated));
  }

  Future<int?> addSelectedHabits() async {
    final current = state.value ?? const PlanGeneratorState();
    if (!current.hasSelections) return null;

    state = AsyncValue.data(
      current.copyWith(
        status: PlanGeneratorStatus.loading,
        clearFailure: true,
      ),
    );

    try {
      final habitNames = current.selectedSuggestions
          .map((s) => s.name)
          .toList();
      final result = await _savePlanHabitsUseCase(habitNames);

      if (_isDisposed) return null;

      final count = result.fold<int?>(
        (failure) {
          final errorMsg = failure.toMessage();
          state = AsyncValue.data(
            current.copyWith(
              status: PlanGeneratorStatus.error,
              errorMessage: errorMsg,
              activeFailure: failure,
            ),
          );
          return null;
        },
        (_) {
          final savedCount = current.selectedCount;
          reset();
          return savedCount;
        },
      );
      return count;
    } catch (e, stack) {
      debugPrint('[PlanGeneratorNotifier] addSelectedHabits error: $e\n$stack');
      final failure = ServerFailure(e.toString());
      state = AsyncValue.data(
        current.copyWith(
          status: PlanGeneratorStatus.error,
          errorMessage: failure.toMessage(),
          activeFailure: failure,
        ),
      );
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(PlanGeneratorState());
  }
}

final planGeneratorNotifierProvider =
    AsyncNotifierProvider<PlanGeneratorNotifier, PlanGeneratorState>(() {
      return PlanGeneratorNotifier();
    });
