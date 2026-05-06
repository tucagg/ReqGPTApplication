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
    final active = controller.activeArtifact;
    final busy = controller.isBusy;

    return Scaffold(
      appBar: AppBar(title: const Text('Artifacts')),
      body: ListView(
        children: [
          ArtifactCard(
            title: 'EARS Gereksinimleri',
            content: artifacts.requirements,
            onGenerate: controller.generateRequirements,
            isThisGenerating: active == ArtifactKey.requirements,
            anyBusy: busy,
          ),
          ArtifactCard(
            title: "Use Case'ler + Mermaid UML",
            content: artifacts.useCases,
            onGenerate: controller.generateUseCases,
            isThisGenerating: active == ArtifactKey.useCases,
            anyBusy: busy,
          ),
          ArtifactCard(
            title: 'İzlenebilirlik Matrisi',
            content: artifacts.traceability,
            onGenerate: controller.generateTraceability,
            isThisGenerating: active == ArtifactKey.traceability,
            anyBusy: busy,
          ),
          ArtifactCard(
            title: 'Mockup Ekranlar',
            content: artifacts.mockups,
            onGenerate: controller.generateMockups,
            isThisGenerating: active == ArtifactKey.mockups,
            anyBusy: busy,
          ),
          ArtifactCard(
            title: 'SRS Belgesi (Markdown)',
            content: artifacts.srs,
            onGenerate: controller.generateSrs,
            isThisGenerating: active == ArtifactKey.srs,
            anyBusy: busy,
          ),
        ],
      ),
    );
  }
}
