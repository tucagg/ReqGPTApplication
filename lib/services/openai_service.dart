import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import '../utils/prompts.dart';

class OpenAiService {
  OpenAiService({http.Client? client, String apiKey = '', String model = 'gpt-4o-mini'})
      : _client = client ?? http.Client(),
        _apiKey = apiKey,
        _model = model;

  final http.Client _client;
  final String _apiKey;
  final String _model;

  Future<String> chat(List<ChatMessage> messages) async {
    if (_apiKey.isEmpty || _apiKey == 'sk-your-api-key-here') {
      return _offlineFallback(messages.last.content);
    }

    final payload = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': ReqGptPrompts.systemPrompt},
        ...messages.map((m) => m.toOpenAiMessage()),
      ],
      'temperature': 0.3,
    };

    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('OpenAI error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['choices'][0]['message']['content'] as String;
  }

  Future<String> generateArtifact(String prompt) async {
    return chat([
      ChatMessage(role: MessageRole.user, content: prompt),
    ]);
  }

  String _offlineFallback(String userText) {
    return '''
Demo mode: OpenAI API key is not configured yet.

Based on your input, I would start requirements elicitation with these questions:
1. Who are the primary users and stakeholders?
2. What problem does the app solve?
3. What are the top 3 user goals?
4. What data should the system store?
5. Which non-functional qualities matter most: security, usability, performance, reliability, or scalability?

User input received:
$userText
''';
  }
}
