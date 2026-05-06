import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';
    final hasKey = (dotenv.env['OPENAI_API_KEY'] ?? '').startsWith('sk-');

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('OpenAI Model'),
              subtitle: Text(model),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(hasKey ? Icons.check_circle_outline : Icons.warning_amber),
              title: const Text('API Key Status'),
              subtitle: Text(hasKey ? 'Configured' : 'Not configured / demo mode'),
            ),
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Production note: API key mobile app içine gömülmemeli. Canlı ürün için backend proxy kullan.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
