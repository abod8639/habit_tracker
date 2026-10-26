import 'dart:convert';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';
import '../models/chat_message_model.dart';
import 'ai_chat_payload_processor.dart';

abstract class AiChatLocalDataSource {
  Future<List<ChatMessageModel>> getChatHistory();
  Future<void> saveChatHistory(List<ChatMessageModel> messages);
  Future<void> clearChatHistory();
}

class AiChatLocalDataSourceImpl implements AiChatLocalDataSource {
  static const String historyKey = 'ai_chat_history';
  final KeyValueStorage _storage;

  AiChatLocalDataSourceImpl({required KeyValueStorage storage})
    : _storage = storage;

  @override
  Future<List<ChatMessageModel>> getChatHistory() async {
    try {
      final raw = await _storage.getRawMetadata(historyKey);
      if (raw == null || raw.trim().isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List || decoded.isEmpty) return [];
      return await AiChatPayloadProcessor.parseMessages(decoded);
    } catch (e) {
      throw CacheException('Failed to read chat history from storage: $e');
    }
  }

  @override
  Future<void> saveChatHistory(List<ChatMessageModel> messages) async {
    try {
      final listToSave = await AiChatPayloadProcessor.serializeMessages(
        messages,
      );
      final jsonStr = jsonEncode(listToSave);
      await _storage.setRawMetadata(historyKey, jsonStr);
    } catch (e) {
      throw CacheException('Failed to write chat history to storage: $e');
    }
  }

  @override
  Future<void> clearChatHistory() async {
    try {
      await _storage.remove(historyKey);
    } catch (e) {
      throw CacheException('Failed to clear chat history in storage: $e');
    }
  }
}
