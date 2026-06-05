import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/reqgpt_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _keyController;
  late TextEditingController _modelController;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final controller = context.read<ReqGptController>();
    _keyController = TextEditingController(text: controller.apiKey);
    _modelController = TextEditingController(text: controller.apiModel);
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _save() {
    final controller = context.read<ReqGptController>();
    controller.setApiKey(_keyController.text);
    controller.setApiModel(_modelController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ayarlar kaydedildi'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReqGptController>();
    final hasKey = controller.apiKey.startsWith('sk-');

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Görünüm ──────────────────────────────────────────────────────
          const _SectionHeader('Görünüm'),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tema'),
                  const SizedBox(height: 10),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Açık'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('Sistem'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Koyu'),
                      ),
                    ],
                    selected: {controller.themeMode},
                    onSelectionChanged: (s) => controller.setThemeMode(s.first),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── API ──────────────────────────────────────────────────────────
          const _SectionHeader('API'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Durum satırı
                  Row(
                    children: [
                      Icon(
                        hasKey ? Icons.check_circle_outline : Icons.warning_amber,
                        color: hasKey ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasKey ? 'API anahtarı yapılandırıldı' : 'API anahtarı girilmedi — demo mod',
                        style: TextStyle(
                          color: hasKey ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // API Key alanı
                  TextField(
                    controller: _keyController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'OpenAI API Anahtarı',
                      hintText: 'sk-...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Model alanı
                  TextField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      hintText: 'gpt-4o-mini',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kaydet butonu
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Kaydet'),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'API anahtarınız yalnızca bu cihazda saklanır ve hiçbir yere gönderilmez.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Hakkında ─────────────────────────────────────────────────────
          const _SectionHeader('Hakkında'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'ReqGPT — AI destekli gereksinim mühendisliği aracı.\n\n'
                'API anahtarınızı platform.openai.com adresinden alabilirsiniz.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
