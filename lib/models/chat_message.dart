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

  Map<String, String> toOpenAiMessage() => {
        'role': role.name,
        'content': content,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        role: MessageRole.values.byName(json['role'] as String),
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
