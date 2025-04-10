abstract class GeminiRepository {
  Future<void> setSystemPrompt(String prompt);
  Stream<String> sendMessage(String message);
}