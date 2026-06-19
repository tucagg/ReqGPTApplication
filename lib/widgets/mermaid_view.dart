import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

/// Mermaid kodunu mermaid.ink servisi üzerinden PNG'ye render eder.
///
/// webview_flutter yalnızca Android/iOS/macOS'u desteklediği için
/// web ve Linux'ta diyagram görünmüyordu. Render'ı sunucu tarafında
/// yapmak bu sorunu çözer, ancak mermaid.ink'in /svg/ çıktısı etiketleri
/// <foreignObject> içine gömülü HTML olarak üretiyor — flutter_svg saf SVG
/// dışındaki HTML içeriğini render edemediği için yazılar kayboluyordu.
/// /img/ (PNG) uç noktası ise sunucuda gerçek bir tarayıcıyla tam render
/// alıp piksel görüntü döndürdüğü için bu sorunu yaşamıyor.
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
  bool _loading = true;
  bool _error = false;
  bool _saving = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _fetchDiagram();
  }

  @override
  void didUpdateWidget(covariant MermaidView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code) {
      _fetchDiagram();
    }
  }

  Future<void> _fetchDiagram() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final encoded =
          base64Url.encode(utf8.encode(widget.code)).replaceAll('=', '');
      final uri = Uri.parse(
        'https://mermaid.ink/img/$encoded?type=png&theme=default&backgroundColor=white',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception('HTTP ${response.statusCode}');
      }
      if (!mounted) return;
      setState(() {
        _imageBytes = response.bodyBytes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
      widget.onRenderError();
    }
  }

  Future<void> _downloadImage(BuildContext context) async {
    final bytes = _imageBytes;
    if (bytes == null) return;
    setState(() => _saving = true);
    try {
      final file = XFile.fromData(
        bytes,
        name: 'mermaid_diagram.png',
        mimeType: 'image/png',
      );
      await Share.shareXFiles([file], subject: 'Mermaid Diyagramı');
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
          Center(
            child: _loading || _imageBytes == null
                ? const CircularProgressIndicator()
                : InteractiveViewer(
                    child: Image.memory(
                      _imageBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
          if (!_loading && _imageBytes != null)
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
