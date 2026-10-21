import '../../domain/entities/chat_message_entity.dart';

/// Data model representing a chat message with defensive parsing
/// and safe JSON serialization.
class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.text,
    required super.isUser,
    super.hasError,
    super.timestamp,
  });

  /// Defensive JSON parser guaranteeing fallback defaults without throwing TypeError.
  factory ChatMessageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ChatMessageModel(
        text: '',
        isUser: false,
        hasError: false,
        timestamp: null,
      );
    }

    return ChatMessageModel(
      text: _parseString(json['text']),
      isUser: _parseBool(json['isUser']),
      hasError: _parseBool(json['hasError']),
      timestamp: _parseDateTime(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'hasError': hasError,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      text: entity.text,
      isUser: entity.isUser,
      hasError: entity.hasError,
      timestamp: entity.timestamp,
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static bool _parseBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
