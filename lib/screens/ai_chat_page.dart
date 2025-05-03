// lib/screens/ai_chat_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:untitled/services/gemini_service.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _controller = TextEditingController();
  String _response = '';
  final FlutterTts _tts = FlutterTts();

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() => _response = 'AI 응답을 기다리는 중...');
    final reply = await GeminiService.getChatResponse(input);
    setState(() => _response = reply);
    await _tts.speak(reply);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 대화')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: '메시지를 입력하세요'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('전송'),
            ),
            const SizedBox(height: 24),
            Text(_response),
          ],
        ),
      ),
    );
  }
}
