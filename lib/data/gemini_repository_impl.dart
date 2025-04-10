import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../domain/gemini_repository.dart';

class GeminiRepositoryImpl implements GeminiRepository {
  static const String apiKey = "";
  static const String modelName = "gemini-2.0-flash";

  late GenerativeModel _model;
  late ChatSession _chatSession;

  GeminiRepositoryImpl() {
    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );
  }

  @override
  Future<void> setSystemPrompt(String prompt) async {
    try {
      final String assetContent = await _getAssetFile();

      final content = Content.text(prompt + assetContent);
      _chatSession = _model.startChat(history: [content]);
    } catch (e) {
      throw Exception('시스템 프롬포트 설정 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Stream<String> sendMessage(String message) async* {
    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      final responseText = response.text ?? '응답을 생성할 수 없습니다.';
      yield responseText;
    } catch (e) {
      yield '메시지 전송 중 오류가 발생했습니다: $e';
      throw Exception('메시지 전송 중 오류가 발생했습니다: $e');
    }
  }

  Future<String> _getAssetFile() async {
    final String loadedContent70 =
        await rootBundle.loadString('assets/national_library_70.txt');
    final String loadedContentGuide =
        await rootBundle.loadString('assets/national_library_guide.txt');
    return loadedContent70 + loadedContentGuide;
  }
}