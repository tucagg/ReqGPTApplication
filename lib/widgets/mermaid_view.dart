import 'package:flutter/material.dart';
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
        ],
      ),
    );
  }
}
