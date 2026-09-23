import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:hive/hive.dart';

class ChatMessage {
  final RxString text;
  final bool isUser;
  final RxBool hasError;

  ChatMessage({
    required String text,
    required this.isUser,
    bool hasError = false,
  }) : text = text.obs,
       hasError = hasError.obs;
}

class AiChatController extends GetxController {
  final GeminiService _geminiService = GeminiService();
  ChatSession? _chatSession;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxString loadingMessage = ''.obs;

  Box? _historyBox;

  Future<Box> _getHistoryBox() async {
    if (_historyBox != null && _historyBox!.isOpen) {
      return _historyBox!;
    }
    _historyBox = await Hive.openBox(_historyBoxName);
    return _historyBox!;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  static const String _historyBoxName = 'ai_chat_history';

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
// You are a highly empathetic, encouraging, and psychological support coach integrated into a Habit Tracker app.
// Your goal is to motivate the user to achieve their goals, build strong habits, and offer psychological support when they feel down or unmotivated.

// Here is the context about the user's habits for today ($todayStr):
// Total Habits: $totalCount
// Completed: $completedCount ($completionRate%)
// List of habits:
// $habitsContext

// Keep your responses concise, friendly, and highly motivating. Adapt your language to the user's input language (especially if they use Arabic, respond in fluent Arabic).
// If the completion rate is low, encourage them to take a small step. If it's high, praise their consistency and discipline.
''';
  }

  Future<void> _initializeChat() async {
    try {
      // 1. Load History from Hive (last 10 messages)
      final box = await _getHistoryBox();
      final storedList = box.get('history', defaultValue: []) as List;
      final loadedMessages = storedList.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return ChatMessage(
          text: map['text'] as String,
          isUser: map['isUser'] as bool,
          hasError: map['hasError'] as bool? ?? false,
        );
      }).toList();

      messages.clear();
      messages.addAll(loadedMessages);

      // 2. Map loaded messages to Content objects for ChatSession history
      // Note: Skip messages with errors when building history
      final List<Content> chatHistory = loadedMessages
          .where((msg) => !msg.hasError.value)
          .map((msg) {
            if (msg.isUser) {
              return Content.text(msg.text.value);
            } else {
              return Content.model([TextPart(msg.text.value)]);
            }
          })
          .toList();

      // 3. Initialize chat session with history
      _chatSession = _geminiService.startChat(
        systemInstruction: _buildSystemInstruction(),
        history: chatHistory,
      );

      // 4. Generate initial greeting only if the chat history is completely empty
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
      content: Content.text(S.current.initialGreeting),
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
      content: Content.text(text),
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

    final List<Content> chatHistory = [];
    for (int i = 0; i < index; i++) {
      final msg = messages[i];
      if (msg.hasError.value) continue;
      if (msg.isUser) {
        chatHistory.add(Content.text(msg.text.value));
      } else {
        chatHistory.add(Content.model([TextPart(msg.text.value)]));
      }
    }

    _chatSession = _geminiService.startChat(
      systemInstruction: _buildSystemInstruction(),
      history: chatHistory,
    );

    await _sendChatMessageWithRetry(
      content: Content.text(userMessage.text.value),
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
    required Content content,
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
        if (_chatSession == null) {
          targetMessage.hasError.value = true;
          if (!isGreeting) {
            Get.snackbar(S.current.error, S.current.unexpectedError);
          }
          break;
        }

        final responseStream = _chatSession!.sendMessageStream(content);

        String accumulatedText = '';
        bool isFirstChunk = true;

        await for (final chunk in responseStream) {
          final chunkText = chunk.text;
          if (chunkText != null && chunkText.isNotEmpty) {
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
      final box = await _getHistoryBox();
      // Keep only the last 10 messages
      final start = messages.length > 10 ? messages.length - 10 : 0;
      final listToSave = messages
          .sublist(start)
          .map(
            (msg) => {
              'text': msg.text.value,
              'isUser': msg.isUser,
              'hasError': msg.hasError.value,
            },
          )
          .toList();
      await box.put('history', listToSave);
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
                final box = await _getHistoryBox();
                await box.delete('history');
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
