import 'package:uuid/uuid.dart';

enum MessageRole { user, assistant, system }

class ChatMessage {
  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;

  Map<String, String> toOpenAiMessage() {
    return {
      'role': role.name,
      'content': content,
    };
  }
}
