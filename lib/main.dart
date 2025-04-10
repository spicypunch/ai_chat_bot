import 'package:ai_chat_bot/presentation/chat_screen.dart';
import 'package:ai_chat_bot/provider/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/gemini_repository_impl.dart';
import 'domain/gemini_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final GeminiRepository geminiRepository = GeminiRepositoryImpl();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChatModel(geminiRepository: geminiRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ChatScreen(),
      ),
    ),
  );
}
