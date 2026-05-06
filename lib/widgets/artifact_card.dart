import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:share_plus/share_plus.dart';

class ArtifactCard extends StatelessWidget {
  const ArtifactCard({
    super.key,
    required this.title,
    required this.content,
    required this.onGenerate,
    required this.isThisGenerating,
    required this.anyBusy,
  });

  final String title;
  final String content;
  final VoidCallback onGenerate;

  /// Bu kartın artifact'ı şu an üretiliyor mu → spinner göster
  final bool isThisGenerating;

  /// Herhangi bir işlem devam ediyor mu → butonu devre dışı bırak
  final bool anyBusy;

  bool get _hasContent => content.isNotEmpty;

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title panoya kopyalandı.')),
      );
    }
  }

  Future<void> _share() async {
    await Share.share(content, subject: title);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleLarge),
                ),
                if (_hasContent) ...[
                  IconButton(
                    tooltip: 'Panoya kopyala',
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: anyBusy ? null : () => _copyToClipboard(context),
                  ),
                  IconButton(
                    tooltip: 'Paylaş',
                    icon: const Icon(Icons.share_outlined),
                    onPressed: anyBusy ? null : _share,
                  ),
                ],
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: anyBusy ? null : onGenerate,
                  icon: isThisGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_hasContent ? 'Yenile' : 'Üret'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_hasContent)
              MarkdownBody(data: content, selectable: true)
            else
              Text(
                'Henüz üretilmedi.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
