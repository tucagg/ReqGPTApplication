import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'mermaid_view.dart';

class ArtifactCard extends StatefulWidget {
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
  final bool isThisGenerating;
  final bool anyBusy;

  @override
  State<ArtifactCard> createState() => _ArtifactCardState();
}

class _ArtifactCardState extends State<ArtifactCard> {
  bool _mermaidError = false;

  bool get _hasContent => widget.content.isNotEmpty;

  static final _mermaidRegex = RegExp(r'```mermaid\n([\s\S]*?)```');

  @override
  void didUpdateWidget(ArtifactCard old) {
    super.didUpdateWidget(old);
    if (old.content != widget.content) {
      setState(() => _mermaidError = false);
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.content));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.title} panoya kopyalandı.')),
      );
    }
  }

  Future<void> _share() async {
    await Share.share(widget.content, subject: widget.title);
  }

  List<_Segment> _parseSegments(String content) {
    final result = <_Segment>[];
    int lastEnd = 0;
    for (final match in _mermaidRegex.allMatches(content)) {
      if (match.start > lastEnd) {
        result.add(_Segment(content.substring(lastEnd, match.start), isMermaid: false));
      }
      result.add(_Segment(match.group(1)!, isMermaid: true));
      lastEnd = match.end;
    }
    if (lastEnd < content.length) {
      result.add(_Segment(content.substring(lastEnd), isMermaid: false));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final segments = _hasContent ? _parseSegments(widget.content) : <_Segment>[];
    final hasMermaid = segments.any((s) => s.isMermaid);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Başlık + aksiyonlar ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
                ),
                if (_hasContent) ...[
                  IconButton(
                    tooltip: 'Panoya kopyala',
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: widget.anyBusy ? null : () => _copyToClipboard(context),
                  ),
                  IconButton(
                    tooltip: 'Paylaş',
                    icon: const Icon(Icons.share_outlined),
                    onPressed: widget.anyBusy ? null : _share,
                  ),
                ],
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: widget.anyBusy ? null : widget.onGenerate,
                  icon: widget.isThisGenerating
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

            // ── İçerik ──────────────────────────────────────────────────
            if (!_hasContent)
              Text(
                'Henüz üretilmedi.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else ...[
              for (final seg in segments)
                if (!seg.isMermaid)
                  MarkdownBody(data: seg.text, selectable: true)
                else
                  _MermaidSection(
                    code: seg.text,
                    onRenderError: () {
                      if (mounted && !_mermaidError) {
                        setState(() => _mermaidError = true);
                      }
                    },
                  ),

              // Render hatası banneri
              if (hasMermaid && _mermaidError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_outlined, size: 18, color: Colors.orange),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text('Diyagram render edilemedi.', style: TextStyle(color: Colors.orange)),
                      ),
                      TextButton.icon(
                        onPressed: widget.anyBusy ? null : widget.onGenerate,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Yeniden Üret'),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segment {
  const _Segment(this.text, {required this.isMermaid});
  final String text;
  final bool isMermaid;
}

class _MermaidSection extends StatefulWidget {
  const _MermaidSection({required this.code, required this.onRenderError});
  final String code;
  final VoidCallback onRenderError;

  @override
  State<_MermaidSection> createState() => _MermaidSectionState();
}

class _MermaidSectionState extends State<_MermaidSection> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MermaidView(
              code: widget.code,
              onRenderError: widget.onRenderError,
            ),
          ),
          const SizedBox(height: 4),
          // Kodu göster/gizle
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => setState(() => _showCode = !_showCode),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showCode ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showCode ? 'Kodu gizle' : 'Mermaid kodunu göster',
                    style: TextStyle(fontSize: 12, color: cs.primary),
                  ),
                ],
              ),
            ),
          ),
          if (_showCode)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                widget.code,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
