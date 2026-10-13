import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class AiChatRemoteDataSource {
  /// Starts or resets the active chat session with system instruction and history.
  void startChatSession({
    required String systemInstruction,
    required List<ChatMessageEntity> history,
  });

  /// Streams chunks of the AI's response for a given user message.
  Stream<String> sendMessageStream(String message);
}

/// Dedicated remote AI service for AI Chat utilizing Gemini.
class AiChatRemoteDataSourceImpl implements AiChatRemoteDataSource {
  final GeminiService geminiService;
  ChatSession? _chatSession;
  String? _lastSystemInstruction;
  List<ChatMessageEntity> _lastHistory = const [];

  AiChatRemoteDataSourceImpl({required this.geminiService});

  @override
  void startChatSession({
    required String systemInstruction,
    required List<ChatMessageEntity> history,
  }) {
    _lastSystemInstruction = systemInstruction;
    _lastHistory = List.from(history);
    final validHistory = history
        .where((msg) => !msg.hasError)
        .map((msg) {
          if (msg.isUser) {
            return Content.text(msg.text);
          } else {
            return Content.model([TextPart(msg.text)]);
          }
        })
        .toList();

    _chatSession = geminiService.startChat(
      systemInstruction: systemInstruction,
      history: validHistory,
    );
  }

  @override
  Stream<String> sendMessageStream(String message) async* {
    if (_chatSession == null) {
      throw GeminiUnknownException('Chat session is not initialized.');
    }

    try {
      final responseStream =
          _chatSession!.sendMessageStream(Content.text(message));
      await for (final chunk in responseStream) {
        final chunkText = chunk.text;
        if (chunkText != null && chunkText.isNotEmpty) {
          yield chunkText;
        }
      }
    } catch (e) {
      if (GeminiService.isModelUnavailableError(e)) {
        final newModel = await GeminiService.trySwitchToWorkingModel();
        if (newModel != null && _lastSystemInstruction != null) {
          startChatSession(
            systemInstruction: _lastSystemInstruction!,
            history: _lastHistory,
          );
          final retryStream =
              _chatSession!.sendMessageStream(Content.text(message));
          await for (final chunk in retryStream) {
            final chunkText = chunk.text;
            if (chunkText != null && chunkText.isNotEmpty) {
              yield chunkText;
            }
          }
          return;
        }
      }
      rethrow;
    }
  }
}

