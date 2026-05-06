import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../models/project_artifacts.dart';
import '../models/session.dart';
import '../utils/prompts.dart';
import 'openai_service.dart';
import 'storage_service.dart';

enum ArtifactKey { requirements, useCases, traceability, mockups, srs }

class ReqGptController extends ChangeNotifier {
  ReqGptController({OpenAiService? openAiService, StorageService? storageService})
      : _openAiService = openAiService ?? OpenAiService(),
        _storage = storageService ?? StorageService() {
    _loadAll();
  }

  final OpenAiService _openAiService;
  final StorageService _storage;

  // ── Durum ────────────────────────────────────────────────────────────────

  final List<ChatMessage> messages = [];
  ProjectArtifacts artifacts = const ProjectArtifacts();
  ThemeMode themeMode = ThemeMode.system;

  /// Tüm oturumlar (geçmiş listesi için)
  final List<Session> sessions = [];

  /// Aktif oturum kimliği
  String _currentSessionId = '';
  String get currentSessionId => _currentSessionId;

  bool _chatLoading = false;
  ArtifactKey? _activeArtifact;
  bool isSessionLoaded = false;

  bool get isChatLoading => _chatLoading;
  ArtifactKey? get activeArtifact => _activeArtifact;
  bool get isBusy => _chatLoading || _activeArtifact != null;

  // ── Yükleme / Kaydetme ───────────────────────────────────────────────────

  Future<void> _loadAll() async {
    final data = await _storage.load();

    if (data != null) {
      final rawTheme = data['themeMode'] as String?;
      if (rawTheme != null) {
        themeMode = ThemeMode.values.byName(rawTheme);
      }

      final rawSessions = data['sessions'] as List<dynamic>?;
      if (rawSessions != null) {
        sessions.addAll(
          rawSessions.map((e) => Session.fromJson(e as Map<String, dynamic>)),
        );
      }

      _currentSessionId = data['currentSessionId'] as String? ?? '';
    }

    // Aktif oturumu mesajlara yükle
    final current = _sessionById(_currentSessionId);
    if (current != null) {
      messages.addAll(current.messages);
      artifacts = current.artifacts;
    } else {
      // Hiç oturum yoksa yeni başlat
      _startFreshSession();
    }

    isSessionLoaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    // Aktif oturumu sessions listesinde güncelle
    _upsertCurrentSession();

    await _storage.save({
      'themeMode': themeMode.name,
      'currentSessionId': _currentSessionId,
      'sessions': sessions.map((s) => s.toJson()).toList(),
    });
  }

  /// Aktif oturumu sessions listesinde oluştur veya güncelle.
  void _upsertCurrentSession() {
    final title = Session.titleFrom(messages);
    final updated = Session(
      id: _currentSessionId,
      title: title,
      createdAt: _sessionById(_currentSessionId)?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      messages: List.from(messages),
      artifacts: artifacts,
    );
    final idx = sessions.indexWhere((s) => s.id == _currentSessionId);
    if (idx >= 0) {
      sessions[idx] = updated;
    } else {
      sessions.insert(0, updated);
    }
  }

  Session? _sessionById(String id) {
    try {
      return sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void _startFreshSession() {
    _currentSessionId = const Uuid().v4();
    messages.clear();
    artifacts = const ProjectArtifacts();
    messages.add(ChatMessage(
      role: MessageRole.assistant,
      content:
          'Merhaba, ben ReqGPT. Proje fikrini yaz; gereksinimleri netleştirmek için sorular sorup SRS çıktısı hazırlayabilirim.',
    ));
  }

  // ── Oturum işlemleri ─────────────────────────────────────────────────────

  /// Yeni boş oturum başlat (mevcut oturumu geçmişe yazar).
  Future<void> newSession() async {
    _upsertCurrentSession();
    _startFreshSession();
    await _persist();
    notifyListeners();
  }

  /// Geçmişten bir oturumu aktif oturum yap.
  Future<void> switchToSession(String id) async {
    if (id == _currentSessionId) return;

    // Önce mevcut oturumu kaydet
    _upsertCurrentSession();

    final target = _sessionById(id);
    if (target == null) return;

    _currentSessionId = id;
    messages.clear();
    messages.addAll(target.messages);
    artifacts = target.artifacts;

    await _persist();
    notifyListeners();
  }

  /// Geçmişten bir oturumu sil.
  Future<void> deleteSession(String id) async {
    if (id == _currentSessionId) {
      // Silinen oturum aktifse yeni oturum başlat
      sessions.removeWhere((s) => s.id == id);
      _startFreshSession();
    } else {
      sessions.removeWhere((s) => s.id == id);
    }
    await _persist();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _persist();
    notifyListeners();
  }

  // ── Sohbet ───────────────────────────────────────────────────────────────

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
      await _persist();
      notifyListeners();
    }
  }

  // ── Artifact üretimi ─────────────────────────────────────────────────────

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
    final ctx = '''
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
      prompt: ReqGptPrompts.srsPrompt(ctx),
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
      await _persist();
      notifyListeners();
    }
  }
}
