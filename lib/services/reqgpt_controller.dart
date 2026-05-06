import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/project_artifacts.dart';
import '../utils/prompts.dart';
import 'openai_service.dart';

enum ArtifactKey { requirements, useCases, traceability, mockups, srs }

class ReqGptController extends ChangeNotifier {
  ReqGptController({OpenAiService? openAiService})
      : _openAiService = openAiService ?? OpenAiService() {
    _addWelcome();
  }

  final OpenAiService _openAiService;
  final List<ChatMessage> messages = [];
  ProjectArtifacts artifacts = const ProjectArtifacts();
  ThemeMode themeMode = ThemeMode.system;

  bool _chatLoading = false;
  ArtifactKey? _activeArtifact;

  /// true sadece sohbet cevabı beklenirken
  bool get isChatLoading => _chatLoading;

  /// Hangi artifact üretiliyor (null ise hiçbiri)
  ArtifactKey? get activeArtifact => _activeArtifact;

  /// Herhangi bir işlem devam ediyor mu (chat veya artifact)
  bool get isBusy => _chatLoading || _activeArtifact != null;

  void _addWelcome() {
    messages.add(ChatMessage(
      role: MessageRole.assistant,
      content:
          'Merhaba, ben ReqGPT. Proje fikrini yaz; gereksinimleri netleştirmek için sorular sorup SRS çıktısı hazırlayabilirim.',
    ));
  }

  void resetConversation() {
    messages.clear();
    artifacts = const ProjectArtifacts();
    _addWelcome();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  String get conversationContext => messages
      .where((m) => m.role != MessageRole.system)
      .map((m) => '${m.role.name.toUpperCase()}: ${m.content}')
      .join('\n\n');

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    messages.add(ChatMessage(role: MessageRole.user, content: trimmed));
    _chatLoading = true;
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
      _chatLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateRequirements() async {
    await _generate(
      key: ArtifactKey.requirements,
      label: 'Gereksinimler',
      prompt: ReqGptPrompts.artifactPrompt(
        'functional and non-functional requirements in EARS style',
        conversationContext,
      ),
      save: (r) => artifacts = artifacts.copyWith(requirements: r),
    );
  }

  Future<void> generateUseCases() async {
    await _generate(
      key: ArtifactKey.useCases,
      label: "Use Case'ler",
      prompt: ReqGptPrompts.artifactPrompt(
        'use cases, scenarios, and Mermaid UML use case diagram code',
        conversationContext,
      ),
      save: (r) => artifacts = artifacts.copyWith(useCases: r),
    );
  }

  Future<void> generateTraceability() async {
    await _generate(
      key: ArtifactKey.traceability,
      label: 'İzlenebilirlik Matrisi',
      prompt: ReqGptPrompts.artifactPrompt(
        'traceability matrix mapping user needs to requirements and artifacts',
        conversationContext,
      ),
      save: (r) => artifacts = artifacts.copyWith(traceability: r),
    );
  }

  Future<void> generateMockups() async {
    await _generate(
      key: ArtifactKey.mockups,
      label: 'Mockup Ekranlar',
      prompt: ReqGptPrompts.mockupsPrompt(conversationContext),
      save: (r) => artifacts = artifacts.copyWith(mockups: r),
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

Mockups:
${artifacts.mockups}

Traceability:
${artifacts.traceability}
''';
    await _generate(
      key: ArtifactKey.srs,
      label: 'SRS Belgesi',
      prompt: ReqGptPrompts.srsPrompt(context),
      save: (r) => artifacts = artifacts.copyWith(srs: r),
    );
  }

  Future<void> _generate({
    required ArtifactKey key,
    required String label,
    required String prompt,
    required void Function(String result) save,
  }) async {
    _activeArtifact = key;
    notifyListeners();
    try {
      final result = await _openAiService.generateArtifact(prompt);
      save(result);
      messages.add(ChatMessage(
        role: MessageRole.assistant,
        content: '✓ $label üretildi. "Artifacts" sekmesinden görüntüleyebilirsin.',
      ));
    } catch (e) {
      messages.add(ChatMessage(
        role: MessageRole.assistant,
        content: '$label üretilemedi: $e',
      ));
    } finally {
      _activeArtifact = null;
      notifyListeners();
    }
  }
}
