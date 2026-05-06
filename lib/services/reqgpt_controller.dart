import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/project_artifacts.dart';
import '../utils/prompts.dart';
import 'openai_service.dart';

class ReqGptController extends ChangeNotifier {
  ReqGptController({OpenAiService? openAiService})
      : _openAiService = openAiService ?? OpenAiService() {
    messages.add(ChatMessage(
      role: MessageRole.assistant,
      content:
          'Merhaba, ben ReqGPT. Proje fikrini yaz; gereksinimleri netleştirmek için sorular sorup SRS çıktısı hazırlayabilirim.',
    ));
  }

  final OpenAiService _openAiService;
  final List<ChatMessage> messages = [];
  ProjectArtifacts artifacts = const ProjectArtifacts();
  bool isLoading = false;

  String get conversationContext => messages
      .where((m) => m.role != MessageRole.system)
      .map((m) => '${m.role.name.toUpperCase()}: ${m.content}')
      .join('\n\n');

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    messages.add(ChatMessage(role: MessageRole.user, content: trimmed));
    isLoading = true;
    notifyListeners();

    try {
      final response = await _openAiService.chat(messages);
      messages.add(ChatMessage(role: MessageRole.assistant, content: response));
    } catch (e) {
      messages.add(ChatMessage(
        role: MessageRole.assistant,
        content: 'Bir hata oluştu: $e',
      ));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateRequirements() async {
    await _generate(
      label: 'Requirements',
      prompt: ReqGptPrompts.artifactPrompt(
        'functional and non-functional requirements in EARS style',
        conversationContext,
      ),
      save: (result) => artifacts = artifacts.copyWith(requirements: result),
    );
  }

  Future<void> generateUseCases() async {
    await _generate(
      label: 'Use Cases',
      prompt: ReqGptPrompts.artifactPrompt(
        'use cases, scenarios, and Mermaid UML use case diagram code',
        conversationContext,
      ),
      save: (result) => artifacts = artifacts.copyWith(useCases: result),
    );
  }

  Future<void> generateTraceability() async {
    await _generate(
      label: 'Traceability Matrix',
      prompt: ReqGptPrompts.artifactPrompt(
        'traceability matrix mapping user needs to requirements and artifacts',
        conversationContext,
      ),
      save: (result) => artifacts = artifacts.copyWith(traceability: result),
    );
  }

  Future<void> generateSrs() async {
    final context = '''
Conversation:
$conversationContext

Requirements:
${artifacts.requirements}

Use cases:
${artifacts.useCases}

Traceability:
${artifacts.traceability}
''';
    await _generate(
      label: 'SRS',
      prompt: ReqGptPrompts.srsPrompt(context),
      save: (result) => artifacts = artifacts.copyWith(srs: result),
    );
  }

  Future<void> _generate({
    required String label,
    required String prompt,
    required void Function(String result) save,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await _openAiService.generateArtifact(prompt);
      save(result);
      messages.add(ChatMessage(
        role: MessageRole.assistant,
        content: '$label üretildi. Artifacts sekmesinden görüntüleyebilirsin.',
      ));
    } catch (e) {
      messages.add(ChatMessage(
        role: MessageRole.assistant,
        content: '$label üretilemedi: $e',
      ));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
