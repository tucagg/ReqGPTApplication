import 'package:uuid/uuid.dart';

import 'chat_message.dart';
import 'project_artifacts.dart';

class Session {
  Session({
    String? id,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    ProjectArtifacts? artifacts,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        messages = messages ?? [],
        artifacts = artifacts ?? const ProjectArtifacts();

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final ProjectArtifacts artifacts;

  /// İlk kullanıcı mesajından oturum başlığı türetir.
  static String titleFrom(List<ChatMessage> messages) {
    final first = messages.firstWhere(
      (m) => m.role == MessageRole.user,
      orElse: () => ChatMessage(role: MessageRole.user, content: 'Yeni Proje'),
    );
    final text = first.content.replaceAll('\n', ' ');
    return text.length > 60 ? '${text.substring(0, 57)}…' : text;
  }

  Session copyWith({
    String? title,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    ProjectArtifacts? artifacts,
  }) {
    return Session(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      artifacts: artifacts ?? this.artifacts,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'artifacts': artifacts.toJson(),
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Proje',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        messages: (json['messages'] as List<dynamic>)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        artifacts: json['artifacts'] != null
            ? ProjectArtifacts.fromJson(json['artifacts'] as Map<String, dynamic>)
            : const ProjectArtifacts(),
      );
}
