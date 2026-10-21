import 'package:flutter/foundation.dart';
import '../models/chat_message_model.dart';

/// Top-level worker functions for background Isolate execution via [compute].
List<ChatMessageModel> _parseMessagesWorker(List<dynamic> rawList) {
  final List<ChatMessageModel> results = [];
  for (final item in rawList) {
    if (item is Map) {
      try {
        final map = Map<String, dynamic>.from(item);
        results.add(ChatMessageModel.fromJson(map));
      } catch (_) {
        // Skip corrupted individual records without failing the entire history
      }
    }
  }
  return results;
}

List<Map<String, dynamic>> _serializeMessagesWorker(List<ChatMessageModel> messages) {
  // Retain the most recent 20 messages to preserve memory and context window
  final start = messages.length > 20 ? messages.length - 20 : 0;
  return messages.sublist(start).map((m) => m.toJson()).toList();
}

String _sanitizeMarkdownWorker(String rawText) {
  if (rawText.isEmpty) return '';
  // Normalize Windows/Unix line endings and trim trailing whitespace
  return rawText.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
}

/// Helper service delegating heavy JSON parsing, message serialization,
/// and markdown manipulation to background Isolates to prevent UI freezing (Jank).
class AiChatPayloadProcessor {
  AiChatPayloadProcessor._();

  /// Offloads parsing of potentially large chat history JSON arrays to an Isolate.
  static Future<List<ChatMessageModel>> parseMessages(List<dynamic> rawList) {
    if (rawList.isEmpty) return Future.value(const []);
    return compute(_parseMessagesWorker, rawList);
  }

  /// Offloads serialization of messages to an Isolate.
  static Future<List<Map<String, dynamic>>> serializeMessages(
    List<ChatMessageModel> messages,
  ) {
    if (messages.isEmpty) return Future.value(const []);
    return compute(_serializeMessagesWorker, messages);
  }

  /// Offloads processing and sanitization of large Markdown text chunks to an Isolate.
  static Future<String> processMarkdown(String rawText) {
    if (rawText.isEmpty) return Future.value('');
    // For very small strings, run synchronously to avoid isolate spawn overhead
    if (rawText.length < 500) {
      return Future.value(_sanitizeMarkdownWorker(rawText));
    }
    return compute(_sanitizeMarkdownWorker, rawText);
  }
}
