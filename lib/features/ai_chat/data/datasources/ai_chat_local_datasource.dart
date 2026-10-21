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
      final storedList = _storage.getJsonList(historyKey);
      if (storedList == null || storedList.isEmpty) return [];
      return await AiChatPayloadProcessor.parseMessages(storedList);
    } catch (e) {
      throw CacheException('Failed to read chat history from storage: $e');
    }
  }

  @override
  Future<void> saveChatHistory(List<ChatMessageModel> messages) async {
    try {
      final listToSave = await AiChatPayloadProcessor.serializeMessages(messages);
      await _storage.setJson(historyKey, listToSave);
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
