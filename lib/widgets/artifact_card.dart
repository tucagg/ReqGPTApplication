import 'package:flutter/material.dart';

class ArtifactCard extends StatelessWidget {
  const ArtifactCard({
    super.key,
    required this.title,
    required this.content,
    required this.onGenerate,
  });

  final String title;
  final String content;
  final VoidCallback onGenerate;

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
                FilledButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              content.isEmpty ? 'Henüz üretilmedi.' : content,
            ),
          ],
        ),
      ),
    );
  }
}
