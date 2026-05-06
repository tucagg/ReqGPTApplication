import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/reqgpt_controller.dart';
import '../widgets/artifact_card.dart';

class ArtifactsScreen extends StatelessWidget {
  const ArtifactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReqGptController>();
    final artifacts = controller.artifacts;

    return Scaffold(
      appBar: AppBar(title: const Text('Generated Artifacts')),
      body: ListView(
        children: [
          ArtifactCard(
            title: 'EARS Requirements',
            content: artifacts.requirements,
            onGenerate: controller.generateRequirements,
          ),
          ArtifactCard(
            title: 'Use Cases + Mermaid UML',
            content: artifacts.useCases,
            onGenerate: controller.generateUseCases,
          ),
          ArtifactCard(
            title: 'Traceability Matrix',
            content: artifacts.traceability,
            onGenerate: controller.generateTraceability,
          ),
          ArtifactCard(
            title: 'SRS Markdown',
            content: artifacts.srs,
            onGenerate: controller.generateSrs,
          ),
        ],
      ),
    );
  }
}
