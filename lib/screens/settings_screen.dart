import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../services/reqgpt_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';
    final hasKey = (dotenv.env['OPENAI_API_KEY'] ?? '').startsWith('sk-');
    final controller = context.watch<ReqGptController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          const _SectionHeader('API'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.smart_toy_outlined),
                  title: const Text('OpenAI Model'),
                  subtitle: Text(model),
                ),
                ListTile(
                  leading: Icon(hasKey ? Icons.check_circle_outline : Icons.warning_amber),
                  title: const Text('API Anahtarı Durumu'),
                  subtitle: Text(hasKey ? 'Yapılandırıldı' : 'Yapılandırılmadı — demo mod'),
                  iconColor: hasKey ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Hakkında'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'ReqGPT — AI destekli gereksinim mühendisliği aracı.\n\n'
                'Üretim notu: API anahtarı uygulamaya gömülmemeli. '
                'Canlı ürün için backend proxy kullan.',
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
