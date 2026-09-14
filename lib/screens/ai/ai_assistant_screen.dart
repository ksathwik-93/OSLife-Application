import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/ai_chat_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/note_provider.dart';
import '../../services/local_ai_engine.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/prompt_chips.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/ai_typing_indicator.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  LifeOSContextData _collectContextData() {
    return LifeOSContextData(
      tasks: context.read<TaskProvider>().tasks,
      events: context.read<CalendarProvider>().events,
      transactions: context.read<ExpenseProvider>().transactions,
      goals: context.read<GoalProvider>().allGoals,
      studySubjects: context.read<StudyProvider>().subjects,
      studyTimetable: context.read<StudyProvider>().timetable,
      studyAssignments: context.read<StudyProvider>().assignments,
      studyExams: context.read<StudyProvider>().exams,
      studySessions: context.read<StudyProvider>().sessions,
      notes: context.read<NoteProvider>().notes,
    );
  }

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    final contextData = _collectContextData();
    final chatProvider = context.read<AIChatProvider>();

    chatProvider.sendMessage(text, contextData: contextData);
    _scrollToBottom();
  }

  void _showClearConfirmDialog(AIChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Row(
          children: [
            Icon(Icons.refresh, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Reset Conversation', style: TextStyle(color: AppColors.onSurface, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear your conversation history and reset the assistant?',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.outline)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryContainer),
            onPressed: () {
              chatProvider.clearChat();
              Navigator.pop(ctx);
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.onPrimaryContainer)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<AIChatProvider>();

    // Scroll to bottom when new AI messages arrive or typing status changes
    if (chatProvider.isTyping) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surfaceContainerLow,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.inversePrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppColors.onPrimaryContainer, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'OSLife',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981), // Active green
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'LOCAL SYNC ACTIVE',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Reset Conversation',
            onPressed: () => _showClearConfirmDialog(chatProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              // Message List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatProvider.messages.length && chatProvider.isTyping) {
                      return const AITypingIndicator();
                    }
                    final msg = chatProvider.messages[index];
                    return ChatBubble(message: msg);
                  },
                ),
              ),

              // Suggested prompt chips bar
              PromptChips(
                onPromptSelected: _handleSendMessage,
              ),

              // Bottom Input Bar
              ChatInputBar(
                isEnabled: !chatProvider.isTyping,
                onSendMessage: _handleSendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
