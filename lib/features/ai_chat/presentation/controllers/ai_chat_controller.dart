import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../../domain/usecases/clear_chat_history_usecase.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/save_chat_history_usecase.dart';
import 'ai_chat_binding.dart';

class ChatMessage {
  final RxString text;
  final bool isUser;
  final RxBool hasError;

  ChatMessage({
    required String text,
    required this.isUser,
    bool hasError = false,
  })  : text = text.obs,
        hasError = hasError.obs;

  ChatMessageEntity toEntity() => ChatMessageEntity(
        text: text.value,
        isUser: isUser,
        hasError: hasError.value,
      );

  factory ChatMessage.fromEntity(ChatMessageEntity entity) => ChatMessage(
        text: entity.text,
        isUser: entity.isUser,
        hasError: entity.hasError,
      );
}

class AiChatController extends GetxController {
  final AiChatRepository _chatRepository;
  final GetChatHistoryUseCase _getChatHistoryUseCase;
  final SaveChatHistoryUseCase _saveChatHistoryUseCase;
  final ClearChatHistoryUseCase _clearChatHistoryUseCase;

  AiChatController({
    AiChatRepository? chatRepository,
    GetChatHistoryUseCase? getChatHistoryUseCase,
    SaveChatHistoryUseCase? saveChatHistoryUseCase,
    ClearChatHistoryUseCase? clearChatHistoryUseCase,
  })  : _chatRepository = chatRepository ?? _resolve<AiChatRepository>(),
        _getChatHistoryUseCase =
            getChatHistoryUseCase ?? _resolve<GetChatHistoryUseCase>(),
        _saveChatHistoryUseCase =
            saveChatHistoryUseCase ?? _resolve<SaveChatHistoryUseCase>(),
        _clearChatHistoryUseCase =
            clearChatHistoryUseCase ?? _resolve<ClearChatHistoryUseCase>();

  static T _resolve<T>() {
    if (!Get.isRegistered<T>()) {
      AiChatBinding().dependencies();
    }
    return Get.find<T>();
  }

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxString loadingMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  String _buildSystemInstruction() {
    final habitController = Get.isRegistered<HabitController>()
        ? Get.find<HabitController>()
        : null;
    final List<HabitEntity> habits = habitController?.habits ?? [];

    final todayStr = todaysDateFormatted();
    final int completedCount = habits.where((h) => h.isCompleted).length;
    final int totalCount = habits.length;

    final completionRate = totalCount == 0
        ? 0
        : (completedCount / totalCount * 100).toInt();

    final isArabic = Get.locale?.languageCode == 'ar';
    final appLanguage = isArabic ? 'Arabic' : 'English';

    String habitsContext = isArabic
        ? "لا توجد عادات يتتبعها المستخدم حالياً."
        : "User has no habits currently tracked.";
    if (habits.isNotEmpty) {
      habitsContext = habits
          .map((h) {
            final status = h.isCompleted
                ? (isArabic ? '✓ مكتملة' : '✓ Completed')
                : (isArabic ? '✗ غير مكتملة' : '✗ Not completed');
            return "- ${h.name} ($status)";
          })
          .join("\n");
    }

    final startDateStr = habitController?.getStartDay() ?? todayStr;
    final dailyHistoryContext = habitController != null
        ? _getHeatmapContext(habitController.heatmapDateSet)
        : (isArabic
              ? "لا يوجد سجل إنجاز متوفر حتى الآن."
              : "No history recorded yet.");

    return '''
You are an elite, empathetic habit coach embedded inside a Habit Tracker app.
Your name is never mentioned unless the user asks.
Your core mission: help the user build momentum, feel understood, and take one concrete action.

━━━━━━━━━━━━━━━━━━━━━━
LANGUAGE & LOCALE RULES
━━━━━━━━━━━━━━━━━━━━━━
✦ The app's current language is: $appLanguage.
✦ You MUST start the conversation (including your initial greeting) and write your response in this language.
✦ Mirror the user's language: if they write Arabic → respond in Arabic. If they write English → respond in English. If they mix → mirror the dominant language.
✦ Maintain natural, high-quality phrasing in the target language (no literal/robotic translations).

━━━━━━━━━━━━━━━━━━━━━━
CONTEXT INJECTED EACH SESSION
━━━━━━━━━━━━━━━━━━━━━━
Today: $todayStr
Total habits: $totalCount
Completed: $completedCount ($completionRate%)
Habits detail:
$habitsContext

━━━━━━━━━━━━━━━━━━━━━━
HISTORICAL PROGRESS DATA
━━━━━━━━━━━━━━━━━━━━━━
✦ Start tracking date: $startDateStr
✦ Daily completion rates (last 30 days, newest to oldest):
$dailyHistoryContext

━━━━━━━━━━━━━━━━━━━━━━
RESPONSE MODE — pick based on $completionRate
━━━━━━━━━━━━━━━━━━━━━━

[SUPPORT MODE — 0–39%]
The user is struggling. Do NOT lecture.
→ Validate their effort, even if small.
→ Shrink the goal: suggest ONE micro-habit they can do in 2 minutes.
→ Normalize setbacks with a short reframe ("Every expert was once a beginner").
→ End with: "What's the one tiny thing you can do right now?"

[MOMENTUM MODE — 40–74%]
The user is moving but not consistent.
→ Acknowledge the real progress they've made.
→ Spotlight the habit closest to completion and encourage finishing it.
→ Give a practical tip relevant to their pending habit (not generic advice).
→ End with: a specific action tied to an unfinished habit.

[CELEBRATION MODE — 75–100%]
The user is crushing it.
→ Open with genuine, specific praise (mention the actual habits they completed).
→ Reinforce their identity: "You're becoming someone who [habit]."
→ Introduce a small next-level challenge or ask about expanding a habit.
→ End with: a forward-looking question or stretch goal.

━━━━━━━━━━━━━━━━━━━━━━
TONE DETECTION — adapt mid-reply
━━━━━━━━━━━━━━━━━━━━━━

If user sounds FRUSTRATED or uses words like (مو قادر، فاشل، ما فيه فايدة، I give up):
→ Stop coaching. Validate first. Say "هذا الإحساس طبيعي جداً..." or "It's okay to feel that way."
→ Then gently reframe: failure = data, not identity.

If user sounds MOTIVATED (حماس، excited, ready):
→ Match their energy. Amplify it. Give them a stretch challenge.

If user seems CONFUSED or asks "what should I do?":
→ Be prescriptive. Give ONE clear action, not options.

If user sends signals of EMOTIONAL DISTRESS (burnout, hopelessness beyond habits):
→ Pause habit talk. Acknowledge their feeling warmly.
→ Suggest: "يمكن تحتاج ترتاح اليوم — الراحة جزء من التقدم"
→ If severe: gently mention talking to someone they trust.

━━━━━━━━━━━━━━━━━━━━━━
STRICT OUTPUT RULES
━━━━━━━━━━━━━━━━━━━━━━

✦ Max 4 sentences per reply unless the user writes more.
✦ Never use bullet lists or numbered lists in responses.
✦ Ask only ONE question per reply, and place it at the end.
✦ Mirror the user's language: if they write Arabic → respond in Arabic.
   If they mix → mirror the dominant language.
✦ Never repeat the same opening twice in a row ("أهلاً!" every time = robotic).
✦ Never give unsolicited health or medical advice.
✦ End EVERY reply with either an action or a single question — never a passive statement.
✦ If you don't know a habit's context, ask ONE clarifying question before advising.

━━━━━━━━━━━━━━━━━━━━━━
PERSONALITY CONSTANTS
━━━━━━━━━━━━━━━━━━━━━━

→ Warm but direct. Not sycophantic.
→ Speaks like a smart friend, not a corporate chatbot.
→ Uses the user's name only if it's available in context.
→ References specific habits by name (never says "your habits" generically).
→ Never says "Great question!" or "Absolutely!".
''';
  }

  Future<void> _initializeChat() async {
    try {
      // 1. Load History from UseCase
      final result = await _getChatHistoryUseCase();
      final List<ChatMessageEntity> loadedEntities = result.fold(
        (failure) => [],
        (entities) => entities,
      );

      final loadedMessages = loadedEntities.map(ChatMessage.fromEntity).toList();
      messages.clear();
      messages.addAll(loadedMessages);

      // 2. Initialize chat session with history via Repository
      _chatRepository.initChatSession(
        systemInstruction: _buildSystemInstruction(),
        history: loadedEntities,
      );

      // 3. Generate initial greeting only if the chat history is completely empty
      if (messages.isEmpty) {
        _generateInitialGreeting();
      } else {
        _scrollToBottom();
      }
    } catch (e) {
      final userFriendlyError = GeminiService.getErrorMessage(e);
      Get.snackbar(S.current.error, userFriendlyError);
      debugPrint('Error Failed to initialize chat: $e');
    }
  }

  Future<void> _generateInitialGreeting() async {
    final greetingMessage = ChatMessage(text: '', isUser: false);
    messages.add(greetingMessage);

    await _sendChatMessageWithRetry(
      text: S.current.initialGreeting,
      targetMessage: greetingMessage,
      isGreeting: true,
    );

    if (greetingMessage.hasError.value) {
      messages.remove(greetingMessage);
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    textController.clear();
    final userMessage = ChatMessage(text: text, isUser: true);
    messages.add(userMessage);
    _scrollToBottom();

    final responseMessage = ChatMessage(text: '', isUser: false);
    messages.add(responseMessage);
    _scrollToBottom();

    await _sendChatMessageWithRetry(
      text: text,
      targetMessage: responseMessage,
    );

    if (responseMessage.hasError.value) {
      userMessage.hasError.value = true;
      messages.remove(responseMessage);
      await _saveHistory();
    }
  }

  Future<void> retryMessage(ChatMessage userMessage) async {
    final index = messages.indexOf(userMessage);
    if (index == -1) return;

    userMessage.hasError.value = false;

    // Remove any trailing messages after this user message
    while (messages.length > index + 1) {
      messages.removeLast();
    }

    final responseMessage = ChatMessage(text: '', isUser: false);
    messages.add(responseMessage);
    _scrollToBottom();

    final List<ChatMessageEntity> historyEntities = [];
    for (int i = 0; i < index; i++) {
      final msg = messages[i];
      if (msg.hasError.value) continue;
      historyEntities.add(msg.toEntity());
    }

    _chatRepository.initChatSession(
      systemInstruction: _buildSystemInstruction(),
      history: historyEntities,
    );

    await _sendChatMessageWithRetry(
      text: userMessage.text.value,
      targetMessage: responseMessage,
    );

    if (responseMessage.hasError.value) {
      userMessage.hasError.value = true;
      messages.remove(responseMessage);
      await _saveHistory();
    }
  }

  double? _extractRetrySeconds(dynamic error) {
    final errorStr = error.toString();
    final regex = RegExp(r'retry in\s+([0-9.]+)\s*s', caseSensitive: false);
    final match = regex.firstMatch(errorStr);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  Future<void> _sendChatMessageWithRetry({
    required String text,
    required ChatMessage targetMessage,
    bool isGreeting = false,
  }) async {
    const int maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      isLoading.value = true;
      targetMessage.hasError.value = false;
      loadingMessage.value = '';

      try {
        final stream = _chatRepository.sendMessageStream(text);

        String accumulatedText = '';
        bool isFirstChunk = true;

        await for (final chunkText in stream) {
          if (chunkText.isNotEmpty) {
            if (isFirstChunk) {
              isLoading.value = false;
              isFirstChunk = false;
              targetMessage.text.value = chunkText;
              accumulatedText = chunkText;
            } else {
              accumulatedText += chunkText;
              targetMessage.text.value = accumulatedText;
            }
            _scrollToBottom();
          }
        }

        await _saveHistory();
        return;
      } catch (e) {
        debugPrint('Attempt $attempt failed with error: $e');

        final errorStr = e.toString().toLowerCase();
        final isRateLimit =
            errorStr.contains('quota') ||
            errorStr.contains('limit') ||
            errorStr.contains('429') ||
            errorStr.contains('resource exhausted');

        if (isRateLimit && attempt < maxAttempts) {
          double? retrySeconds = _extractRetrySeconds(e);
          retrySeconds ??= (4.0 * attempt);

          for (int sec = retrySeconds.ceil(); sec > 0; sec--) {
            final isArabic = Get.locale?.languageCode == 'ar';
            loadingMessage.value = isArabic
                ? 'تم تجاوز حد الطلبات. جاري إعادة المحاولة خلال $sec ثانية...'
                : 'Rate limit exceeded. Retrying in $sec seconds...';
            await Future.delayed(const Duration(seconds: 1));
          }
          continue;
        } else {
          targetMessage.hasError.value = true;
          if (!isGreeting) {
            final userFriendlyError = GeminiService.getErrorMessage(e);
            Get.snackbar(S.current.error, userFriendlyError);
          }
          break;
        }
      } finally {
        isLoading.value = false;
        loadingMessage.value = '';
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveHistory() async {
    try {
      final entities = messages.map((m) => m.toEntity()).toList();
      await _saveChatHistoryUseCase(entities);
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  Future<void> clearChat() async {
    Get.dialog(
      AlertDialog(
        title: Text(S.current.clearChatTitle),
        content: Text(S.current.clearChatConfirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(S.current.cancel),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              messages.clear();
              try {
                await _clearChatHistoryUseCase();
              } catch (e) {
                debugPrint('Error clearing chat history: $e');
              }
              _initializeChat();
            },
            child: Text(
              S.current.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  String _getHeatmapContext(Map<DateTime, int> heatmap) {
    if (heatmap.isEmpty) {
      return Get.locale?.languageCode == 'ar'
          ? "لا يوجد سجل إنجاز متوفر حتى الآن."
          : "No history recorded yet.";
    }

    // Sort dates descending (newest first)
    final sortedDates = heatmap.keys.toList()..sort((a, b) => b.compareTo(a));

    // Limit to the last 30 days to avoid overloading context
    final recentDates = sortedDates.take(30).toList();

    final isArabic = Get.locale?.languageCode == 'ar';

    return recentDates
        .map((date) {
          final dateStr =
              "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
          final percent = heatmap[date]! * 10;
          return isArabic
              ? "- $dateStr: نسبة الإنجاز $percent%"
              : "- $dateStr: $percent% completed";
        })
        .join("\n");
  }
}
