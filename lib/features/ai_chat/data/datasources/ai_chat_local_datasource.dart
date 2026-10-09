import 'package:hive/hive.dart';
import '../models/chat_message_model.dart';

abstract class AiChatLocalDataSource {
  Future<List<ChatMessageModel>> getChatHistory();
  Future<void> saveChatHistory(List<ChatMessageModel> messages);
  Future<void> clearChatHistory();
}

class AiChatLocalDataSourceImpl implements AiChatLocalDataSource {
  static const String historyBoxName = 'ai_chat_history';
  Box? _historyBox;

  Future<Box> _getHistoryBox() async {
    if (_historyBox != null && _historyBox!.isOpen) {
      return _historyBox!;
    }
    _historyBox = await Hive.openBox(historyBoxName);
    return _historyBox!;
  }

  @override
  Future<List<ChatMessageModel>> getChatHistory() async {
    final box = await _getHistoryBox();
    final storedList = box.get('history', defaultValue: []) as List;
    return storedList.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return ChatMessageModel.fromJson(map);
    }).toList();
  }

  @override
  Future<void> saveChatHistory(List<ChatMessageModel> messages) async {
    final box = await _getHistoryBox();
    // Keep only the last 10 messages for token and memory efficiency
    final start = messages.length > 10 ? messages.length - 10 : 0;
    final listToSave = messages
        .sublist(start)
        .map((m) => m.toJson())
        .toList();
    await box.put('history', listToSave);
  }

  @override
  Future<void> clearChatHistory() async {
    final box = await _getHistoryBox();
    await box.delete('history');
  }
}
