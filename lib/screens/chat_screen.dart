import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/reqgpt_controller.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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

  Future<void> _confirmReset(ReqGptController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Proje'),
        content: const Text('Mevcut konuşma ve tüm artifact\'lar silinecek. Devam edilsin mi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sıfırla')),
        ],
      ),
    );
    if (confirmed == true) controller.resetConversation();
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
            tooltip: 'İşlemler',
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
                case 'reset':
                  _confirmReset(controller);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'requirements', child: Text('Gereksinimleri Üret (EARS)')),
              const PopupMenuItem(value: 'usecases', child: Text('Use Case\'leri Üret')),
              const PopupMenuItem(value: 'traceability', child: Text('İzlenebilirlik Matrisi Üret')),
              const PopupMenuItem(value: 'mockups', child: Text('Mockup Ekranlar Üret')),
              const PopupMenuItem(value: 'srs', child: Text('SRS Belgesi Derle')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: Text('Yeni Proje Başlat', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) => ChatBubble(
                message: controller.messages[index],
              ),
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
                        hintText: 'Proje fikrini veya cevabını yaz...',
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
