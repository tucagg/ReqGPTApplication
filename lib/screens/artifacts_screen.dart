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
    final loading = controller.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Artifacts')),
      body: ListView(
        children: [
          ArtifactCard(
            title: 'EARS Gereksinimleri',
            content: artifacts.requirements,
            onGenerate: controller.generateRequirements,
            isLoading: loading,
          ),
          ArtifactCard(
            title: 'Use Case\'ler + Mermaid UML',
            content: artifacts.useCases,
            onGenerate: controller.generateUseCases,
            isLoading: loading,
          ),
          ArtifactCard(
            title: 'İzlenebilirlik Matrisi',
            content: artifacts.traceability,
            onGenerate: controller.generateTraceability,
            isLoading: loading,
          ),
          ArtifactCard(
            title: 'Mockup Ekranlar',
            content: artifacts.mockups,
            onGenerate: controller.generateMockups,
            isLoading: loading,
          ),
          ArtifactCard(
            title: 'SRS Belgesi (Markdown)',
            content: artifacts.srs,
            onGenerate: controller.generateSrs,
            isLoading: loading,
          ),
        ],
      ),
    );
  }
}
