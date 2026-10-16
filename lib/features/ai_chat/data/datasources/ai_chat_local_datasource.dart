import 'package:habit_tracker/core/storage/key_value_storage.dart';
import '../models/chat_message_model.dart';

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
    final storedList = _storage.getJsonList(historyKey);
    if (storedList == null) return [];
    return storedList.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return ChatMessageModel.fromJson(map);
    }).toList();
  }

  @override
  Future<void> saveChatHistory(List<ChatMessageModel> messages) async {
    // Keep only the last 10 messages for token and memory efficiency
    final start = messages.length > 10 ? messages.length - 10 : 0;
    final listToSave = messages.sublist(start).map((m) => m.toJson()).toList();
    await _storage.setJson(historyKey, listToSave);
  }

  @override
  Future<void> clearChatHistory() async {
    await _storage.remove(historyKey);
  }
}
