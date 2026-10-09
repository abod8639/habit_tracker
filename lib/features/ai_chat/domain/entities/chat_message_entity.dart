/// Pure domain entity representing a chat message in the AI coach conversation.
class ChatMessageEntity {
  final String text;
  final bool isUser;
  final bool hasError;
  final DateTime? timestamp;

  const ChatMessageEntity({
    required this.text,
    required this.isUser,
    this.hasError = false,
    this.timestamp,
  });

  ChatMessageEntity copyWith({
    String? text,
    bool? isUser,
    bool? hasError,
    DateTime? timestamp,
  }) {
    return ChatMessageEntity(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      hasError: hasError ?? this.hasError,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
