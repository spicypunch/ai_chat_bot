import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../domain/gemini_repository.dart';

class ChatModel extends ChangeNotifier {
  final GeminiRepository geminiRepository;
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  bool _isListening = false;
  String _recognizedText = "";

  ChatModel({required this.geminiRepository}) {
    _initializeGemini();
    _initTts();
    _initSpeech();
  }

  bool _isInitialized = false;
  bool _isLoading = false;

  final List<Map<String, String>> _messages = [
    {"sender": "ai", "message": "안녕하세요. 무엇을 도와드릴까요?"},
  ];

  List<Map<String, String>> get messages => _messages;

  bool get isLoading => _isLoading;

  bool get isListening => _isListening;

  String get recognizedText => _recognizedText;

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
  }

  Future<void> _initSpeech() async {
    speech.statusListener = (status) {
      print("음성 인식 상태: $status");
      if (status == 'done') {
        _handleSpeechResults();
      } else if (status == 'notListening') {
        _isListening = false;
        notifyListeners();
      }
    };

    speech.errorListener = (error) {
      print("음성 인식 오류: $error");
      _isListening = false;
      notifyListeners();
    };

    bool available = await speech.initialize();
    if (!available) {
      print("음성 인식을 사용할 수 없습니다");
    }
  }

  void _handleSpeechResults() {
    _isListening = false;
    notifyListeners();

    if (_recognizedText.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 500), () {
        sendMessageToGemini(_recognizedText);
        _recognizedText = "";
      });
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();
  }

  Future<void> startListening() async {
    if (!_isListening) {
      _recognizedText = "";
      _isListening = true;
      notifyListeners();

      try {
        await speech.listen(
          onResult: (result) {
            _recognizedText = result.recognizedWords;
            notifyListeners();
          },
          listenFor: Duration(seconds: 30),     // 최대 30초 동안 듣기
          pauseFor: Duration(seconds: 3),       // 5초 동안 말이 없으면 자동 종료
          localeId: "ko_KR",                    // 한국어 설정
        );
      } catch (e) {
        print("음성 인식 시작 오류: $e");
        _isListening = false;
        notifyListeners();
      }
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await speech.stop();
      _isListening = false;
      final textToSend = _recognizedText;

      if (textToSend.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 100), () {
          sendMessageToGemini(textToSend);
        });
        _recognizedText = "";
      }

      notifyListeners();
    }
  }

  Future<void> _initializeGemini() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      notifyListeners();

      const String systemPrompt = """
        당신은 국립 중앙도서관의 AI 도우미입니다. 
        국립 중앙도서관에 관한 모든 질문에 친절하게 답변해 주세요.
        다른 주제에 대한 질문을 받으면 정중하게 국립 중앙도서관 관련 질문으로 안내해 주세요.
      """;

      await geminiRepository.setSystemPrompt(systemPrompt);
      _isInitialized = true;
    } catch (e) {
      addMessage("시스템 초기화 중 오류가 발생했습니다. 다시 시도해 주세요: $e", "ai");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addMessage(String message, String sender) {
    _messages.add({"sender": sender, "message": message});
    notifyListeners();
  }

  Future<void> sendMessageToGemini(String message) async {
    if (!_isInitialized) {
      await _initializeGemini();
    }

    addMessage(message, "user");
    _isLoading = true;
    notifyListeners();

    try {
      addMessage("...", "ai");
      String fullResponse = "";

      await for (final chunk in geminiRepository.sendMessage(message)) {
        fullResponse = chunk;
      }

      _messages.removeLast();
      addMessage(fullResponse, "ai");

      await speak(fullResponse);
    } catch (e) {
      _messages.removeLast();
      addMessage("메시지 처리 중 오류가 발생했습니다: $e", "ai");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }
}
