import '../models/chat_message_model.dart';
import 'local_ai_engine.dart';

/// Prepared interface for OpenAI / Gemini / Custom LLM / Local rule-based AI Assistant.
abstract class AIService {
  Future<ChatMessageModel> sendMessage(String userMessage, {LifeOSContextData? contextData});
  Future<String> generateSuggestion({LifeOSContextData? contextData});
}

/// Local Rule-based AI implementation powered by LocalAIEngine and local LifeOS storage.
class LocalLifeOSAIService implements AIService {
  @override
  Future<ChatMessageModel> sendMessage(String userMessage, {LifeOSContextData? contextData}) async {
    // Realistic micro-delay to simulate conversational processing
    await Future.delayed(const Duration(milliseconds: 600));

    final aiText = contextData != null
        ? LocalAIEngine.generateResponse(userMessage, contextData)
        : "I've received your query: '$userMessage'. Please ensure local OSLife data is available.";

    return ChatMessageModel(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: aiText,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<String> generateSuggestion({LifeOSContextData? contextData}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (contextData != null && contextData.studyExams.isNotEmpty) {
      final exam = contextData.studyExams.first;
      return "You have an exam coming up (${exam.title}). I recommend reviewing your notes tonight.";
    }
    return "What would you like to plan or review across your OSLife today?";
  }
}

/// Kept as an alias for backwards compatibility
class MockAIService extends LocalLifeOSAIService {}
