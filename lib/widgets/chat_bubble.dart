import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:intl/intl.dart';

import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final scheme = Theme.of(context).colorScheme;
    final timeStr = DateFormat('HH:mm').format(message.createdAt);
    final textColor = isUser ? scheme.onPrimaryContainer : scheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Kullanıcı mesajları düz metin; asistan mesajları markdown
            isUser
                ? SelectableText(
                    message.content,
                    style: TextStyle(color: textColor),
                  )
                : MarkdownBody(
                    data: message.content,
                    selectable: true,
                    styleSheet: _buildSheet(context, textColor),
                  ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildSheet(BuildContext context, Color textColor) {
    final base = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return MarkdownStyleSheet(
      p: base.bodyMedium?.copyWith(color: textColor),
      strong: base.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      em: base.bodyMedium?.copyWith(
        color: textColor,
        fontStyle: FontStyle.italic,
      ),
      h1: base.titleLarge?.copyWith(color: textColor),
      h2: base.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
      h3: base.titleSmall?.copyWith(color: textColor, fontWeight: FontWeight.bold),
      h4: base.bodyLarge?.copyWith(color: textColor, fontWeight: FontWeight.bold),
      listBullet: base.bodyMedium?.copyWith(color: textColor),
      code: base.bodySmall?.copyWith(
        fontFamily: 'monospace',
        color: scheme.onSecondaryContainer,
        backgroundColor: scheme.secondaryContainer,
      ),
      codeblockDecoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: scheme.primary, width: 3),
        ),
      ),
      blockquote: base.bodyMedium?.copyWith(
        color: textColor.withValues(alpha: 0.75),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
