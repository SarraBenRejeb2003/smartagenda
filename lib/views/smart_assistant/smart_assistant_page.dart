import 'package:flutter/material.dart';

import '../../viewmodels/smart_assistant_viewmodel.dart';

class SmartAssistantPage extends StatefulWidget {
  const SmartAssistantPage({super.key});

  @override
  State<SmartAssistantPage> createState() =>
      _SmartAssistantPageState();
}

class _SmartAssistantPageState
    extends State<SmartAssistantPage> {
  final SmartAssistantViewModel _viewModel =
      SmartAssistantViewModel();

  final TextEditingController _messageController =
      TextEditingController();

  final List<Map<String, String>> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _viewModel.isLoading) {
      return;
    }

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': message,
      });
    });

    _messageController.clear();

    final response = await _viewModel.sendMessage(message);

    if (!mounted) {
      return;
    }

    setState(() {
      _messages.add({
        'sender': 'assistant',
        'message': response,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeMessage()
                : _buildMessages(),
          ),

          if (_viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),

          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 70,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bonjour 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Je suis votre assistant SmartAgenda.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Essayez par exemple :\n'
              '• Quels sont mes rendez-vous aujourd’hui ?\n'
              '• Quels sont mes rendez-vous demain ?\n'
              '• Quel est mon prochain rendez-vous ?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message['sender'] == 'user';

        return Align(
          alignment: isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * 0.8,
            ),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser
                  ? Theme.of(context)
                      .colorScheme
                      .primaryContainer
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message['message'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Posez votre question...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed:
                  _viewModel.isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}