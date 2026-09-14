import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/ai_service.dart';
import '../services/local_ai_engine.dart';

class AIChatProvider extends ChangeNotifier {
  final AIService _aiService;

  late final List<ChatMessageModel> _messages;
  bool _isTyping = false;

  AIChatProvider({AIService? aiService})
      : _aiService = aiService ?? LocalLifeOSAIService() {
    _resetInitialMessages();
  }

  void _resetInitialMessages() {
    _messages = [
      ChatMessageModel(
        id: 'ai_welcome',
        text: "Hello! I am your **LifeOS AI Assistant**.\n\n"
            "I'm synced with your local **Tasks, Calendar, Expenses, Goals, Study Planner, and Notes**.\n\n"
            "Ask me anything or select a prompt chip below to get started!",
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ),
    ];
  }

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  Future<void> sendMessage(String text, {LifeOSContextData? contextData}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final userMsg = ChatMessageModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: cleanText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    try {
      final aiResponse = await _aiService.sendMessage(cleanText, contextData: contextData);
      _messages.add(aiResponse);
    } catch (e) {
      _messages.add(
        ChatMessageModel(
          id: 'err_${DateTime.now().millisecondsSinceEpoch}',
          text: "Sorry, I encountered an issue analyzing your local data: $e",
          sender: MessageSender.ai,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _resetInitialMessages();
    _isTyping = false;
    notifyListeners();
  }
}
