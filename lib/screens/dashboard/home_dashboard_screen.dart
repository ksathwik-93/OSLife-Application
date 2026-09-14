import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/ai_glow_badge.dart';
import '../../providers/task_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ai_chat_provider.dart';
import '../../services/local_ai_engine.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTaskFilter = 'All';
  
  // Local completed task toggles for smooth immediate UI response
  final Set<String> _locallyCompletedTasks = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  LifeOSContextData _collectLifeOSContext() {
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

  void _showAskAIModal(BuildContext context) {
    final modalInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryContainer, Color(0xFF9333EA)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ask AI Assistant',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Instant smart productivity insights & actions',
                            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/ai');
                      },
                      icon: const Icon(Icons.open_in_new, size: 14, color: AppColors.primary),
                      label: const Text('Full View', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Suggested Prompts',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPromptChip('What should I do today?'),
                    _buildPromptChip('Show my pending tasks'),
                    _buildPromptChip('How much did I spend this month?'),
                    _buildPromptChip('What are my current goals?'),
                    _buildPromptChip('Help me plan my study time'),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: modalInputController,
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                          decoration: const InputDecoration(
                            hintText: 'Ask OSLife Assistant...',
                            hintStyle: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onSubmitted: (val) {
                            final text = val.trim();
                            Navigator.pop(ctx);
                            if (text.isNotEmpty) {
                              context.read<AIChatProvider>().sendMessage(text, contextData: _collectLifeOSContext());
                            }
                            context.push('/ai');
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final text = modalInputController.text.trim();
                          Navigator.pop(ctx);
                          if (text.isNotEmpty) {
                            context.read<AIChatProvider>().sendMessage(text, contextData: _collectLifeOSContext());
                          }
                          context.push('/ai');
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromptChip(String label) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        context.read<AIChatProvider>().sendMessage(label, contextData: _collectLifeOSContext());
        context.push('/ai');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.onSurface, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final calendarProvider = Provider.of<CalendarProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final noteProvider = Provider.of<NoteProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);

    final user = authProvider.currentUser;
    final userName = user?.name.split(' ').first ?? 'Alex';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? AppConstants.paddingDesktop : AppConstants.paddingMobile,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar / Top Navigation Bar
                  _buildTopNavigationBar(userName, context),
                  const SizedBox(height: 24),

                  // 1. Personalized Greeting & 2. Current Date Banner
                  _buildGreetingAndDateHeader(userName, user?.streakDays ?? 14),
                  const SizedBox(height: 20),

                  // 3. Search Bar with Ask AI Chip
                  _buildSearchBarSection(context),
                  const SizedBox(height: 24),

                  // 4. Quick Action Buttons (4 distinct actions: Add Task, Add Note, Add Expense, Study)
                  _buildQuickActionButtonsSection(context, isDesktop),
                  const SizedBox(height: 24),

                  // 10. AI Assistant Card with "Ask AI" button
                  _buildAIAssistantCard(context, taskProvider, calendarProvider, expenseProvider, goalProvider, studyProvider),
                  const SizedBox(height: 28),

                  // Responsive Bento Grid Layout
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (Tasks + Recent Activity)
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: [
                              // 5. Today's Tasks Card
                              _buildTodaysTasksCard(context, taskProvider),
                              const SizedBox(height: 24),
                              // 6. Calendar Preview Card
                              _buildCalendarPreviewCard(context, calendarProvider),
                              const SizedBox(height: 24),
                              // 11. Recent Activity Section
                              _buildRecentActivitySection(noteProvider, taskProvider, expenseProvider, goalProvider, studyProvider),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column (Expense Summary + Goals Progress + Study Progress)
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              // 7. Expense Summary Card (Income, Expenses, Balance)
                              _buildExpenseSummaryCard(context, expenseProvider),
                              const SizedBox(height: 24),
                              // 9. Study Progress Card (Circular Indicator)
                              _buildStudyProgressCard(context, studyProvider),
                              const SizedBox(height: 24),
                              // 8. Goals Progress Card (Progress Bars)
                              _buildGoalsProgressCard(context, goalProvider),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        // 5. Today's Tasks Card
                        _buildTodaysTasksCard(context, taskProvider),
                        const SizedBox(height: 20),
                        // 6. Calendar Preview Card
                        _buildCalendarPreviewCard(context, calendarProvider),
                        const SizedBox(height: 20),
                        // 7. Expense Summary Card
                        _buildExpenseSummaryCard(context, expenseProvider),
                        const SizedBox(height: 20),
                        // 9. Study Progress Card
                        _buildStudyProgressCard(context, studyProvider),
                        const SizedBox(height: 20),
                        // 8. Goals Progress Card
                        _buildGoalsProgressCard(context, goalProvider),
                        const SizedBox(height: 20),
                        // 11. Recent Activity Section
                        _buildRecentActivitySection(noteProvider, taskProvider, expenseProvider, goalProvider, studyProvider),
                      ],
                    ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Top Navigation Bar
  Widget _buildTopNavigationBar(String userName, BuildContext context) {
    return Row(
      children: [
        // Brand Logo
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryContainer, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OSLife',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'AI Productivity Suite',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const Spacer(),
        // AI Assistant Quick Trigger
        IconButton(
          onPressed: () => _showAskAIModal(context),
          tooltip: 'Ask AI Assistant',
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.psychology_rounded, color: AppColors.primary, size: 20),
          ),
        ),
        const SizedBox(width: 6),
        // Notifications Indicator
        Stack(
          children: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications: All systems updated smoothly.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Notifications',
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant, size: 20),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        // Settings Button
        IconButton(
          onPressed: () => context.push('/settings'),
          tooltip: 'Settings',
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        // User Profile Avatar
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceContainerHighest,
              child: Text(
                userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 1. Personalized Greeting & 2. Current Date Header
  Widget _buildGreetingAndDateHeader(String userName, int streakDays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()}, $userName 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    _getFormattedDate(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Streak Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.tertiaryContainer.withValues(alpha: 0.35),
                const Color(0xFFB45309).withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.tertiary.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '$streakDays-Day Streak',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.tertiary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Search Bar
  Widget _buildSearchBarSection(BuildContext context) {
    return GlassCard(
      onTap: () {
        final query = _searchController.text.trim();
        if (query.isNotEmpty) {
          context.push('/search?q=${Uri.encodeComponent(query)}');
        } else {
          context.push('/search');
        }
      },
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      borderRadius: 18,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
            onPressed: () {
              final query = _searchController.text.trim();
              if (query.isNotEmpty) {
                context.push('/search?q=${Uri.encodeComponent(query)}');
              } else {
                context.push('/search');
              }
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  context.push('/search?q=${Uri.encodeComponent(val.trim())}');
                } else {
                  context.push('/search');
                }
              },
              onTap: () {
                final query = _searchController.text.trim();
                if (query.isNotEmpty) {
                  context.push('/search?q=${Uri.encodeComponent(query)}');
                } else {
                  context.push('/search');
                }
              },
              style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
              decoration: const InputDecoration(
                hintText: 'Search tasks, notes, events, expenses, goals...',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.onSurfaceVariant),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
              },
            ),
          const SizedBox(width: 6),
          // Ask AI Button Chip inside Search Bar
          InkWell(
            onTap: () => _showAskAIModal(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, Color(0xFF9333EA)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'Ask AI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Quick Action Buttons (4 distinct actions: Add Task, Add Note, Add Expense, Study)
  Widget _buildQuickActionButtonsSection(BuildContext context, bool isDesktop) {
    final actions = [
      {
        'title': 'Add Task',
        'subtitle': 'Create new item',
        'icon': Icons.add_task_rounded,
        'color': AppColors.primary,
        'route': '/tasks',
      },
      {
        'title': 'Add Note',
        'subtitle': 'Voice or text memo',
        'icon': Icons.edit_note_rounded,
        'color': AppColors.secondary,
        'route': '/notes',
      },
      {
        'title': 'Add Expense',
        'subtitle': 'Track spending',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppColors.tertiary,
        'route': '/expense',
      },
      {
        'title': 'Study',
        'subtitle': 'Focus session',
        'icon': Icons.school_rounded,
        'color': const Color(0xFF10B981),
        'route': '/study',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = isDesktop
                ? (constraints.maxWidth - 36) / 4
                : (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: actions.map((act) {
                final color = act['color'] as Color;
                final title = act['title'] as String;
                final subtitle = act['subtitle'] as String;
                final icon = act['icon'] as IconData;
                final route = act['route'] as String;

                return SizedBox(
                  width: cardWidth,
                  child: GlassCard(
                    onTap: () => context.push(route),
                    padding: const EdgeInsets.all(16),
                    borderRadius: 18,
                    border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // 10. AI Assistant Card with "Ask AI" button
  Widget _buildAIAssistantCard(
    BuildContext context,
    TaskProvider taskProvider,
    CalendarProvider calendarProvider,
    ExpenseProvider expenseProvider,
    GoalProvider goalProvider,
    StudyProvider studyProvider,
  ) {
    final pendingCount = taskProvider.tasks.where((t) => !t.isCompleted).length;
    final activeGoalsCount = goalProvider.activeGoalsCount;
    final studyHours = studyProvider.totalWeeklyStudyHours;
    final nextExam = studyProvider.nextUpcomingExam;

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 20,
      border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.4), width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryContainer, Color(0xFF9333EA)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Assistant Insight',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Daily Schedule Optimization',
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              const AIGlowBadge(label: 'Smart Focus'),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.onSurfaceVariant),
              children: [
                const TextSpan(text: 'Good day! You have '),
                TextSpan(
                  text: '$pendingCount pending tasks',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: '$activeGoalsCount active goals',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                TextSpan(
                  text: '. Logged ${studyHours.toStringAsFixed(1)} hrs of study this week. ${nextExam != null ? 'Recommended focus: Prep for ${nextExam.title} (${nextExam.daysRemaining} days left).' : 'Keep up the momentum!'}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              // Prominent "Ask AI" button
              ElevatedButton.icon(
                onPressed: () => _showAskAIModal(context),
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('Ask AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: AppColors.primaryContainer.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => context.push('/study'),
                icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                label: const Text('Start Focus Session', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Today's Tasks Card
  Widget _buildTodaysTasksCard(BuildContext context, TaskProvider taskProvider) {
    // Use only real provider tasks — no sample fallback.
    final query = _searchController.text.trim().toLowerCase();

    final filteredTasks = taskProvider.tasks.where((t) {
      final matchesQuery = query.isEmpty || t.title.toLowerCase().contains(query) || t.category.toLowerCase().contains(query);
      final isCompleted = _locallyCompletedTasks.contains(t.id) || t.isCompleted;
      if (_selectedTaskFilter == 'Pending') return matchesQuery && !isCompleted;
      if (_selectedTaskFilter == 'High Priority') return matchesQuery && t.priority == 'High';
      return matchesQuery;
    }).toList();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Today's Tasks",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredTasks.where((t) => !_locallyCompletedTasks.contains(t.id) && !t.isCompleted).length} pending',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/tasks'),
                child: const Row(
                  children: [
                    Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Category filter pills
          Row(
            children: ['All', 'Pending', 'High Priority'].map((filter) {
              final isSelected = _selectedTaskFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTaskFilter = filter;
                      });
                    }
                  },
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                  ),
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (filteredTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No tasks matching your filter.', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            )
          else
            ...filteredTasks.map((t) {
              final isDone = _locallyCompletedTasks.contains(t.id) || t.isCompleted;

              Color priorityColor;
              if (t.priority == 'High') {
                priorityColor = const Color(0xFFEF4444);
              } else if (t.priority == 'Medium') {
                priorityColor = AppColors.primary;
              } else {
                priorityColor = AppColors.secondary;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_locallyCompletedTasks.contains(t.id)) {
                            _locallyCompletedTasks.remove(t.id);
                          } else {
                            _locallyCompletedTasks.add(t.id);
                          }
                        });
                        taskProvider.toggleTask(t.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.primaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: isDone ? AppColors.primaryContainer : AppColors.outline,
                            width: 2,
                          ),
                        ),
                        child: isDone
                            ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDone ? AppColors.onSurfaceVariant : AppColors.onSurface,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: priorityColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  t.priority.toUpperCase(),
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: priorityColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t.category,
                                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 18),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // 6. Calendar Preview Card
  Widget _buildCalendarPreviewCard(BuildContext context, CalendarProvider calendarProvider) {
    // Use only real provider events — no sample fallback.
    final displayEvents = calendarProvider.events;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.event_available_rounded, color: AppColors.secondary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Calendar Preview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/calendar'),
                child: const Row(
                  children: [
                    Text('Calendar', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.secondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (displayEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy_rounded, size: 36, color: AppColors.onSurfaceVariant),
                    SizedBox(height: 8),
                    Text(
                      'No upcoming events scheduled.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ...displayEvents.take(2).map((ev) {
              final monthLabel = [
                'JAN','FEB','MAR','APR','MAY','JUN',
                'JUL','AUG','SEP','OCT','NOV','DEC',
              ][ev.startTime.month - 1];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    // Date badge block
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${ev.startTime.day}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.secondary),
                          ),
                          Text(
                            monthLabel,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ev.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                '${ev.startTime.hour}:${ev.startTime.minute.toString().padLeft(2, '0')} - ${ev.endTime.hour}:${ev.endTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  ev.location,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // 7. Expense Summary Card (Income, Expenses, Balance)
  Widget _buildExpenseSummaryCard(BuildContext context, ExpenseProvider expenseProvider) {
    // Use real provider values — zero for new users with no transactions.
    final income = expenseProvider.totalIncome;
    final totalExpenses = expenseProvider.totalExpenses;
    final balance = expenseProvider.netBalance;

    // Build dynamic weekly bars from last-7-days data.
    final now = DateTime.now();
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dailyTotals = List<double>.generate(7, (i) {
      final day = now.subtract(Duration(days: now.weekday - 1 - i));
      return expenseProvider.transactions
          .where((t) =>
              !t.isIncome &&
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day)
          .fold(0.0, (sum, t) => sum + t.amount);
    });
    final maxDaily = dailyTotals.reduce((a, b) => a > b ? a : b);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.tertiary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Expense Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/expense'),
                child: const Text('Overview', style: TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 3 Financial Metric Tiles (Income, Expenses, Balance)
          Row(
            children: [
              Expanded(
                child: _buildFinancialMetricTile('Income', '+₹${income.toStringAsFixed(0)}', Icons.arrow_upward_rounded, const Color(0xFF10B981)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFinancialMetricTile('Expenses', '-₹${totalExpenses.toStringAsFixed(0)}', Icons.arrow_downward_rounded, AppColors.tertiary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFinancialMetricTile('Balance', '₹${balance.toStringAsFixed(0)}', Icons.account_balance_rounded, AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Weekly Breakdown',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          // Dynamic weekly bar chart — all bars empty/flat for new users.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final ratio = maxDaily > 0 ? (dailyTotals[i] / maxDaily).clamp(0.05, 1.0) : 0.05;
              final isToday = i == now.weekday - 1;
              return _buildExpenseBar(dayLabels[i], ratio, isToday);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetricTile(String label, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBar(String day, double ratio, bool isHighlight) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 60 * ratio,
          decoration: BoxDecoration(
            gradient: isHighlight
                ? const LinearGradient(
                    colors: [AppColors.tertiary, Color(0xFFF59E0B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: isHighlight ? null : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.tertiary : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // 8. Goals Progress Card
  Widget _buildGoalsProgressCard(BuildContext context, GoalProvider goalProvider) {
    final displayGoals = goalProvider.allGoals.take(3).toList();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flag_rounded, color: AppColors.tertiary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Goals Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/goals'),
                child: const Row(
                  children: [
                    Text('View All', style: TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.tertiary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (displayGoals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No active goals set.', style: TextStyle(color: AppColors.onSurfaceVariant)),
            )
          else
            ...displayGoals.map((g) {
              final title = g.title;
              final progress = g.calculatedProgress;
              final category = g.category;
              final target = g.daysRemaining < 0
                  ? '${g.daysRemaining.abs()}d overdue'
                  : '${g.daysRemaining} days left';
              
              Color color = AppColors.primary;
              if (category.toLowerCase() == 'finance') color = AppColors.tertiary;
              if (category.toLowerCase() == 'health') color = const Color(0xFF4ADE80);
              if (category.toLowerCase() == 'personal') color = AppColors.secondary;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(category, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                        Text(target, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // 9. Study Progress Card (Circular Indicator)
  Widget _buildStudyProgressCard(BuildContext context, StudyProvider studyProvider) {
    final progressRatio = studyProvider.weeklyProgressRatio;
    final progressPercent = (progressRatio * 100).toInt();
    final topSubject = studyProvider.subjects.isNotEmpty
        ? studyProvider.subjects.first.name
        : 'No subjects registered yet';
    final completedHours = studyProvider.totalWeeklyStudyHours;
    final targetHours = studyProvider.targetWeeklyStudyHours;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_rounded, color: Color(0xFF10B981), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Study Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => context.push('/study'),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF10B981)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                // Circular Progress Indicator
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: progressRatio.clamp(0.0, 1.0),
                          strokeWidth: 7,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topSubject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${completedHours.toStringAsFixed(1)} / ${targetHours.toStringAsFixed(1)} hrs weekly goal',
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      if (completedHours > 0)
                        const Text(
                          '🔥 Active study streak',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tertiary),
                        )
                      else
                        const Text(
                          'Start studying to build your streak',
                          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/study'),
              icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
              label: const Text('Continue Learning', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: BorderSide(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 11. Recent Activity Section
  Widget _buildRecentActivitySection(
    NoteProvider noteProvider,
    TaskProvider taskProvider,
    ExpenseProvider expenseProvider,
    GoalProvider goalProvider,
    StudyProvider studyProvider,
  ) {
    final activities = <Map<String, dynamic>>[];

    if (studyProvider.sessions.isNotEmpty) {
      final s = studyProvider.sessions.first;
      activities.add({
        'title': 'Logged ${s.durationMinutes}m Study: ${s.topic}',
        'time': 'Recent',
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF10B981),
      });
    }

    if (taskProvider.tasks.isNotEmpty) {
      final t = taskProvider.tasks.first;
      activities.add({
        'title': '${t.isCompleted ? "Completed Task" : "Task Active"}: ${t.title}',
        'time': 'Today',
        'icon': Icons.task_alt_rounded,
        'color': AppColors.primary,
      });
    }

    if (expenseProvider.expenses.isNotEmpty) {
      final e = expenseProvider.expenses.first;
      activities.add({
        'title': 'Logged Expense: ₹${e.amount.toStringAsFixed(2)} (${e.title})',
        'time': 'Today',
        'icon': Icons.receipt_long_rounded,
        'color': AppColors.tertiary,
      });
    }

    if (goalProvider.allGoals.isNotEmpty) {
      final g = goalProvider.allGoals.first;
      activities.add({
        'title': 'Goal Progress: ${g.title} (${(g.calculatedProgress * 100).toInt()}%)',
        'time': 'Active',
        'icon': Icons.flag_rounded,
        'color': AppColors.secondary,
      });
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history_rounded, size: 36, color: AppColors.onSurfaceVariant),
                    SizedBox(height: 8),
                    Text(
                      'No recent activity yet.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ...activities.asMap().entries.map((entry) {
              final idx = entry.key;
              final act = entry.value;
              final title = act['title'] as String;
              final time = act['time'] as String;
              final icon = act['icon'] as IconData;
              final color = act['color'] as Color;
              final isLast = idx == activities.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: color.withValues(alpha: 0.4)),
                        ),
                        child: Icon(icon, size: 14, color: color),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 28,
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            time,
                            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}
