import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MermaidView extends StatefulWidget {
  const MermaidView({
    super.key,
    required this.code,
    required this.onRenderError,
  });

  final String code;
  final VoidCallback onRenderError;

  @override
  State<MermaidView> createState() => _MermaidViewState();
}

class _MermaidViewState extends State<MermaidView> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _error = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'MermaidError',
        onMessageReceived: (_) {
          if (mounted) {
            setState(() {
              _loading = false;
              _error = true;
            });
            widget.onRenderError();
          }
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadHtmlString(_buildHtml(widget.code));
  }

  String _buildHtml(String code) {
    final safeCode = code
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    return '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body { margin: 0; padding: 8px; background: white; display: flex; justify-content: center; }
  #diagram svg { max-width: 100%; height: auto; }
</style>
</head>
<body>
<div id="diagram" class="mermaid">$safeCode</div>
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script>
  mermaid.initialize({ startOnLoad: false, theme: 'default' });
  mermaid.run({ querySelector: '#diagram' })
    .catch(function(e) {
      MermaidError.postMessage(e ? e.toString() : 'render error');
    });
</script>
</body>
</html>
''';
  }

  Future<void> _downloadImage(BuildContext context) async {
    if (_loading || _error) return;
    setState(() => _saving = true);
    try {
      final result = await _controller.runJavaScriptReturningResult(
        "document.querySelector('#diagram svg') ? document.querySelector('#diagram svg').outerHTML : ''",
      );

      final svgHtml = result.toString().replaceAll(RegExp(r'^"|"$'), '');
      if (svgHtml.isEmpty) throw Exception('Diyagram henüz hazır değil');

      final svgContent = svgHtml
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\"', '"')
          .replaceAll(r"\'", "'");

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/mermaid_${DateTime.now().millisecondsSinceEpoch}.svg',
      );
      await file.writeAsString(svgContent, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/svg+xml')],
        subject: 'Mermaid Diyagramı',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İndirilemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return const SizedBox.shrink();
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          if (!_loading && !_error)
            Positioned(
              top: 6,
              right: 6,
              child: _saving
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Material(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _downloadImage(context),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.download_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
