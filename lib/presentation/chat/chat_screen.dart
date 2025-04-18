import 'package:ai_chat_bot/presentation/chat/user_message_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_view_model.dart';
import 'ai_message_view.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final scrollController = ScrollController();
  final textController = TextEditingController();
  bool isSpeaking = true;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatModel = Provider.of<ChatViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSpeaking = !isSpeaking;
              });
              if (isSpeaking == false) {
                chatModel.stopSpeaking();
              }
            },
            icon: Icon(isSpeaking ? Icons.volume_down : Icons.volume_off),
            tooltip: '음성 중지',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: chatModel.messages.length,
              itemBuilder: (context, index) {
                final message = chatModel.messages[index];
                final sender = message["sender"] ?? "";
                final content = message["message"] ?? "";
                if (sender == "ai") {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: AiMessageView(
                      chat: content,
                    ),
                  );
                } else if (sender == "user") {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: UserMessageView(chat: content),
                  );
                }
                return null;
              },
            ),
          ),
          if (chatModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          if (chatModel.isListening)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: Colors.red),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        '말씀해 주세요...',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          _buildMessageInput(context, chatModel),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, ChatViewModel chatModel) {
    if (chatModel.isListening &&
        chatModel.recognizedText.isNotEmpty &&
        textController.text != chatModel.recognizedText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        textController.text = chatModel.recognizedText;
        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );
      });
    }

    void sendMessage() {
      if (textController.text.isNotEmpty) {
        final message = textController.text;
        textController.clear();
        chatModel.sendMessageToGemini(message);
      }
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          IconButton(
            onPressed: () {
              if (chatModel.isListening) {
                chatModel.stopListening();
              } else {
                chatModel.startListening();
              }
            },
            icon: Icon(
              chatModel.isListening ? Icons.stop : Icons.mic,
              color: chatModel.isListening ? Colors.red : null,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
