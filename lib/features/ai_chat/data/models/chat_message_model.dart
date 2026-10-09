import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.text,
    required super.isUser,
    super.hasError,
    super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      hasError: json['hasError'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
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
}
