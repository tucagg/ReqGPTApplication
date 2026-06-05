import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/reqgpt_controller.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.onNewSession, required this.onGoToSettings});

  /// Called when a new session is started to keep the Chat tab active.
  final VoidCallback onNewSession;

  /// Called when the user taps "Go to Settings" in the API key banner.
  final VoidCallback onGoToSettings;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(ReqGptController controller) {
    final text = _textController.text.trim();
    if (text.isEmpty || controller.isBusy) return;
    _textController.clear();
    controller.sendMessage(text).then((_) => _scrollToBottom());
    _scrollToBottom();
  }

  Future<void> _confirmNewSession(ReqGptController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Project'),
        content: const Text(
            'The current conversation will be saved to history and a new session will start.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.newSession();
      widget.onNewSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReqGptController>();

    if (!controller.isBusy) _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReqGPT'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Actions',
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'requirements':
                  controller.generateRequirements();
                case 'usecases':
                  controller.generateUseCases();
                case 'traceability':
                  controller.generateTraceability();
                case 'mockups':
                  controller.generateMockups();
                case 'srs':
                  controller.generateSrs();
                case 'new':
                  _confirmNewSession(controller);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'requirements', child: Text('Generate Requirements (EARS)')),
              const PopupMenuItem(
                  value: 'usecases', child: Text('Generate Use Cases')),
              const PopupMenuItem(
                  value: 'traceability', child: Text('Generate Traceability Matrix')),
              const PopupMenuItem(
                  value: 'mockups', child: Text('Generate Mockup Screens')),
              const PopupMenuItem(value: 'srs', child: Text('Compile SRS Document')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'new',
                child: Text(
                  'New Project',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (!controller.apiKey.startsWith('sk-'))
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              content: const Text(
                '🔑  No API key set. Go to Settings → paste your OpenAI API key (sk-...) → Save.\n'
                'Get a key at platform.openai.com/api-keys',
              ),
              actions: [
                TextButton(
                  onPressed: widget.onGoToSettings,
                  child: const Text('Go to Settings'),
                ),
              ],
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) =>
                  ChatBubble(message: controller.messages[index]),
            ),
          ),
          if (controller.isChatLoading)
            LinearProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(controller),
                      decoration: const InputDecoration(
                        hintText: 'Describe your project idea or answer a question...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: controller.isBusy ? null : () => _send(controller),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
