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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReqGptController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReqGPT'),
        actions: [
          IconButton(
            tooltip: 'Generate requirements',
            icon: const Icon(Icons.rule),
            onPressed: controller.isLoading ? null : controller.generateRequirements,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) => ChatBubble(
                message: controller.messages[index],
              ),
            ),
          ),
          if (controller.isLoading) const LinearProgressIndicator(),
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
                      decoration: const InputDecoration(
                        hintText: 'Proje fikrini veya cevabını yaz...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            final text = _textController.text;
                            _textController.clear();
                            controller.sendMessage(text);
                          },
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
