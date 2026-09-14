import '../models/task_model.dart';
import '../models/event_model.dart';
import '../models/expense_model.dart';
import '../models/goal_model.dart';
import '../models/study_model.dart';
import '../models/note_model.dart';

/// Context snapshot holding active data from all LifeOS modules
class LifeOSContextData {
  final List<TaskModel> tasks;
  final List<EventModel> events;
  final List<ExpenseModel> transactions;
  final List<GoalModel> goals;
  final List<SubjectModel> studySubjects;
  final List<TimetableSlotModel> studyTimetable;
  final List<AssignmentModel> studyAssignments;
  final List<ExamModel> studyExams;
  final List<StudySessionModel> studySessions;
  final List<NoteModel> notes;

  const LifeOSContextData({
    this.tasks = const [],
    this.events = const [],
    this.transactions = const [],
    this.goals = const [],
    this.studySubjects = const [],
    this.studyTimetable = const [],
    this.studyAssignments = const [],
    this.studyExams = const [],
    this.studySessions = const [],
    this.notes = const [],
  });
}

/// Local rule-based AI reasoning engine for LifeOS
class LocalAIEngine {
  LocalAIEngine._();

  static String generateResponse(String prompt, LifeOSContextData context) {
    final query = prompt.trim().toLowerCase();

    // 1. "What should I do today?" / Daily agenda
    if (_matchesQuery(query, [
      'what should i do today',
      'what to do today',
      'today schedule',
      'daily plan',
      'plan today',
      'my day',
      'today agenda',
      'what is on my plate today',
    ])) {
      return _generateTodayAgenda(context);
    }

    // 2. "Show my pending tasks" / Tasks
    if (_matchesQuery(query, [
      'show my pending tasks',
      'pending tasks',
      'my tasks',
      'what tasks are pending',
      'show tasks',
      'list tasks',
      'unfinished tasks',
      'to do',
      'todo',
    ])) {
      return _generatePendingTasksResponse(context);
    }

    // 3. "How much did I spend this month?" / Expenses / Budget
    if (_matchesQuery(query, [
      'how much did i spend this month',
      'how much did i spend',
      'spend this month',
      'monthly spend',
      'monthly expense',
      'my expenses',
      'total spend',
      'expenditure',
      'spending',
    ])) {
      return _generateMonthlySpendResponse(context);
    }

    // 4. "What are my current goals?" / Goals / Milestones
    if (_matchesQuery(query, [
      'what are my current goals',
      'my current goals',
      'current goals',
      'my goals',
      'show goals',
      'goal progress',
      'milestones',
    ])) {
      return _generateGoalsResponse(context);
    }

    // 5. "Help me plan my study time" / Study planner
    if (_matchesQuery(query, [
      'help me plan my study time',
      'plan my study time',
      'study plan',
      'study planner',
      'study schedule',
      'plan study',
      'help study',
      'exam preparation',
      'exams',
      'assignments',
    ])) {
      return _generateStudyPlanResponse(context);
    }

    // 6. Notes / Ideas
    if (_matchesQuery(query, [
      'my notes',
      'show notes',
      'notes',
      'pinned notes',
      'recent notes',
    ])) {
      return _generateNotesResponse(context);
    }

    // 7. Calendar / Events
    if (_matchesQuery(query, [
      'my calendar',
      'calendar events',
      'upcoming events',
      'schedule',
      'meetings',
    ])) {
      return _generateEventsResponse(context);
    }

    // 8. Overview / LifeOS Summary
    if (_matchesQuery(query, [
      'summary',
      'overview',
      'lifeos overview',
      'how am i doing',
      'status report',
    ])) {
      return _generateOverviewResponse(context);
    }

    // 9. Greetings
    if (_matchesQuery(query, [
      'hello',
      'hi',
      'hey',
      'good morning',
      'good afternoon',
      'good evening',
    ])) {
      return "Hello! I am your OSLife AI Assistant. I have live access to your local Tasks, Calendar, Expenses, Goals, Study Planner, and Notes.\n\n"
          "Here are some quick things you can ask me:\n"
          "• 'What should I do today?'\n"
          "• 'Show my pending tasks'\n"
          "• 'How much did I spend this month?'\n"
          "• 'What are my current goals?'\n"
          "• 'Help me plan my study time'";
    }

    // 10. Help
    if (_matchesQuery(query, ['help', 'what can you do', 'commands'])) {
      return "Here is what I can analyze for you based on your local OSLife data:\n\n"
          "📋 **Tasks**: Pending items, priority breakdown, and overdue alerts.\n"
          "📅 **Calendar**: Today's meetings, time slots, and upcoming events.\n"
          "💰 **Expenses**: Monthly spending summary, category breakdown, and net balance.\n"
          "🎯 **Goals**: Milestone progress, active target dates, and achievements.\n"
          "📚 **Study Planner**: Exam countdowns, assignment deadlines, and timetable tracking.\n"
          "📝 **Notes**: Recent and pinned notes retrieval.\n\n"
          "Try tapping any of the suggested prompt chips below or type a query!";
    }

    // Fallback: smart keyword search across data
    return _generateSmartFallback(prompt, context);
  }

  static bool _matchesQuery(String query, List<String> patterns) {
    for (final p in patterns) {
      if (query.contains(p)) return true;
    }
    return false;
  }

  // --- Detailed generators ---

  static String _generateTodayAgenda(LifeOSContextData ctx) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Mon ... 7 = Sun

    // Today's events
    final todayEvents = ctx.events.where((e) {
      return e.startTime.year == now.year &&
          e.startTime.month == now.month &&
          e.startTime.day == now.day;
    }).toList();

    // Pending tasks
    final pendingTasks = ctx.tasks.where((t) => !t.isCompleted).toList();
    final highPriorityTasks = pendingTasks.where((t) => t.priority.toLowerCase() == 'high').toList();

    // Today's timetable slots
    final todaySlots = ctx.studyTimetable.where((s) => s.dayOfWeek == todayWeekday).toList();

    // Upcoming exams within 3 days
    final urgentExams = ctx.studyExams.where((e) => !e.isCompleted && e.daysRemaining >= 0 && e.daysRemaining <= 3).toList();

    final buffer = StringBuffer();
    buffer.writeln("📅 **Your Daily OSLife Briefing**\n");

    // 1. Calendar & Classes
    if (todayEvents.isNotEmpty || todaySlots.isNotEmpty) {
      buffer.writeln("🕒 **Scheduled Commitments Today:**");
      for (final slot in todaySlots) {
        buffer.writeln("• ${slot.startTime} - ${slot.endTime}: **${slot.subjectName}** (${slot.room})");
      }
      for (final event in todayEvents) {
        final timeStr = "${_formatHour(event.startTime)} - ${_formatHour(event.endTime)}";
        buffer.writeln("• $timeStr: **${event.title}**${event.location.isNotEmpty ? ' @ ${event.location}' : ''}");
      }
      buffer.writeln();
    } else {
      buffer.writeln("🕒 **Schedule:** No calendar events or classes scheduled for today.\n");
    }

    // 2. High priority action items
    if (highPriorityTasks.isNotEmpty) {
      buffer.writeln("🔥 **Top Priority Tasks to Tackle:**");
      for (final t in highPriorityTasks.take(4)) {
        buffer.writeln("• **${t.title}** [${t.category}]");
      }
      buffer.writeln();
    } else if (pendingTasks.isNotEmpty) {
      buffer.writeln("📋 **Next Tasks to Complete:**");
      for (final t in pendingTasks.take(3)) {
        buffer.writeln("• ${t.title} [${t.priority} Priority]");
      }
      buffer.writeln();
    } else {
      buffer.writeln("✅ **Tasks:** All caught up! No pending tasks.\n");
    }

    // 3. Urgent Academic Alerts
    if (urgentExams.isNotEmpty) {
      buffer.writeln("⚠️ **Urgent Exam Alert:**");
      for (final exam in urgentExams) {
        final dayText = exam.daysRemaining == 0 ? "Today!" : "in ${exam.daysRemaining} day(s)";
        buffer.writeln("• **${exam.title}** (${exam.subjectName}) is **$dayText**");
      }
      buffer.writeln();
    }

    buffer.writeln("💡 **AI Recommendation:** Focus your high-energy window on completing your top priority tasks, and set aside 45 minutes this evening for review.");
    return buffer.toString();
  }

  static String _generatePendingTasksResponse(LifeOSContextData ctx) {
    final pending = ctx.tasks.where((t) => !t.isCompleted).toList();
    if (pending.isEmpty) {
      return "🎉 **Great job!** You have no pending tasks right now. All your tasks are completed!";
    }

    final high = pending.where((t) => t.priority.toLowerCase() == 'high').toList();
    final medium = pending.where((t) => t.priority.toLowerCase() == 'medium').toList();
    final low = pending.where((t) => t.priority.toLowerCase() == 'low').toList();

    final buffer = StringBuffer();
    buffer.writeln("📋 **You have ${pending.length} pending task(s):**\n");

    if (high.isNotEmpty) {
      buffer.writeln("🔴 **High Priority (${high.length}):**");
      for (final t in high) {
        buffer.writeln("• **${t.title}** (${t.category}) — Due ${_formatDate(t.dueDate)}");
      }
      buffer.writeln();
    }

    if (medium.isNotEmpty) {
      buffer.writeln("🟡 **Medium Priority (${medium.length}):**");
      for (final t in medium) {
        buffer.writeln("• **${t.title}** (${t.category}) — Due ${_formatDate(t.dueDate)}");
      }
      buffer.writeln();
    }

    if (low.isNotEmpty) {
      buffer.writeln("🟢 **Low Priority (${low.length}):**");
      for (final t in low) {
        buffer.writeln("• **${t.title}** (${t.category})");
      }
      buffer.writeln();
    }

    buffer.writeln("💡 *Tip: Address the ${high.length} high-priority item(s) first to minimize deadline friction.*");
    return buffer.toString();
  }

  static String _generateMonthlySpendResponse(LifeOSContextData ctx) {
    final now = DateTime.now();
    final thisMonthTransactions = ctx.transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();

    final expenses = thisMonthTransactions.where((t) => !t.isIncome).toList();
    final income = thisMonthTransactions.where((t) => t.isIncome).toList();

    final totalExpense = expenses.fold<double>(0.0, (s, t) => s + t.amount);
    final totalIncome = income.fold<double>(0.0, (s, t) => s + t.amount);
    final netSavings = totalIncome - totalExpense;

    if (expenses.isEmpty && income.isEmpty) {
      return "📊 **Monthly Spending Analysis**\n\nNo transactions have been recorded for the current month (${_monthName(now.month)} ${now.year}).";
    }

    // Category breakdown
    final categoryTotals = <String, double>{};
    for (final exp in expenses) {
      categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0.0) + exp.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer();
    buffer.writeln("💰 **Financial Summary for ${_monthName(now.month)} ${now.year}:**\n");
    buffer.writeln("• **Total Expenses:** \$${totalExpense.toStringAsFixed(2)}");
    buffer.writeln("• **Total Income:** \$${totalIncome.toStringAsFixed(2)}");
    buffer.writeln("• **Net Balance:** ${netSavings >= 0 ? '+' : ''}\$${netSavings.toStringAsFixed(2)}\n");

    if (sortedCategories.isNotEmpty) {
      buffer.writeln("🏷️ **Top Spending Categories:**");
      for (final entry in sortedCategories.take(4)) {
        final pct = totalExpense > 0 ? (entry.value / totalExpense * 100).toStringAsFixed(1) : '0';
        buffer.writeln("• **${entry.key}**: \$${entry.value.toStringAsFixed(2)} ($pct%)");
      }
      buffer.writeln();
    }

    if (expenses.isNotEmpty) {
      buffer.writeln("🔍 **Recent Outflows:**");
      for (final exp in expenses.take(3)) {
        buffer.writeln("• ${exp.title}: \$${exp.amount.toStringAsFixed(2)} (${exp.category})");
      }
      buffer.writeln();
    }

    if (totalIncome > 0 && netSavings > 0) {
      final rate = (netSavings / totalIncome * 100).toStringAsFixed(1);
      buffer.writeln("💡 **Health Check:** Your current savings rate this month is **$rate%**. Great job maintaining a positive cashflow!");
    }

    return buffer.toString();
  }

  static String _generateGoalsResponse(LifeOSContextData ctx) {
    if (ctx.goals.isEmpty) {
      return "🎯 **Goals:** You haven't set any goals yet in OSLife. Head over to the Goals section to define your target achievements!";
    }

    final activeGoals = ctx.goals.where((g) => !g.isAchieved).toList();
    final achievedGoals = ctx.goals.where((g) => g.isAchieved).toList();

    final buffer = StringBuffer();
    buffer.writeln("🎯 **Your Active Goals Progress (${activeGoals.length} Active / ${achievedGoals.length} Completed):**\n");

    for (final goal in activeGoals) {
      final pct = (goal.calculatedProgress * 100).toInt();
      final completedM = goal.milestones.where((m) => m.isCompleted).length;
      final totalM = goal.milestones.length;

      buffer.writeln("• **${goal.title}** — **$pct% Complete**");
      buffer.writeln("  Category: ${goal.category} | Priority: ${goal.priority}");
      if (totalM > 0) {
        buffer.writeln("  Milestones: $completedM of $totalM completed");
      }
      buffer.writeln("  Target Date: ${_formatDate(goal.targetDate)}");
      buffer.writeln();
    }

    if (achievedGoals.isNotEmpty) {
      buffer.writeln("🏆 **Recently Achieved:**");
      for (final g in achievedGoals.take(2)) {
        buffer.writeln("• **${g.title}** (${g.category}) ✅");
      }
      buffer.writeln();
    }

    buffer.writeln("💡 **Strategy:** Focus on the next pending milestone in your highest priority goal to maintain momentum.");
    return buffer.toString();
  }

  static String _generateStudyPlanResponse(LifeOSContextData ctx) {
    final buffer = StringBuffer();
    buffer.writeln("📚 **Study Planner & Academic Roadmap**\n");

    // Upcoming exams
    final upcomingExams = ctx.studyExams.where((e) => !e.isCompleted && e.daysRemaining >= 0).toList()
      ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

    // Pending assignments
    final pendingAssignments = ctx.studyAssignments.where((a) => !a.isCompleted).toList();

    // Study hours
    final totalHours = ctx.studySubjects.fold<double>(0.0, (s, subj) => s + subj.completedHoursThisWeek);
    final targetHours = ctx.studySubjects.fold<double>(0.0, (s, subj) => s + subj.targetHoursPerWeek);

    buffer.writeln("⏱️ **Weekly Study Hours:** ${totalHours.toStringAsFixed(1)}h / ${targetHours.toStringAsFixed(1)}h target\n");

    if (upcomingExams.isNotEmpty) {
      buffer.writeln("🚨 **Upcoming Exams:**");
      for (final exam in upcomingExams.take(3)) {
        final days = exam.daysRemaining == 0 ? "Today" : "in ${exam.daysRemaining} days";
        buffer.writeln("• **${exam.title}** (${exam.subjectName}) — **$days** [Weight: ${exam.weightPercentage}%]");
      }
      buffer.writeln();
    }

    if (pendingAssignments.isNotEmpty) {
      buffer.writeln("📝 **Pending Assignments:**");
      for (final asgn in pendingAssignments.take(3)) {
        buffer.writeln("• **${asgn.title}** (${asgn.subjectName}) — Due ${_formatDate(asgn.dueDate)}");
      }
      buffer.writeln();
    }

    // Recommended focus
    if (upcomingExams.isNotEmpty) {
      final priorityExam = upcomingExams.first;
      buffer.writeln("🎯 **AI Study Recommendation:**");
      buffer.writeln("Your nearest exam is **${priorityExam.title}** (${daysText(priorityExam.daysRemaining)}).");
      buffer.writeln("We recommend scheduling two 45-minute Pomodoro blocks tonight focusing on revision and practice questions.");
    } else {
      buffer.writeln("🎯 **AI Study Recommendation:** Review your current subjects and log your study sessions to stay on track for your weekly target!");
    }

    return buffer.toString();
  }

  static String _generateNotesResponse(LifeOSContextData ctx) {
    if (ctx.notes.isEmpty) {
      return "📝 You have no notes saved yet. You can create quick notes, meeting minutes, and ideas in the Notes module.";
    }

    final pinned = ctx.notes.where((n) => n.isPinned).toList();
    final recent = ctx.notes.where((n) => !n.isPinned).take(3).toList();

    final buffer = StringBuffer();
    buffer.writeln("📝 **Your OSLife Notes Summary (${ctx.notes.length} Total):**\n");

    if (pinned.isNotEmpty) {
      buffer.writeln("📌 **Pinned Notes:**");
      for (final n in pinned) {
        final preview = n.content.length > 50 ? "${n.content.substring(0, 50)}..." : n.content;
        buffer.writeln("• **${n.title}** [${n.tag}]: \"$preview\"");
      }
      buffer.writeln();
    }

    if (recent.isNotEmpty) {
      buffer.writeln("🕒 **Recent Notes:**");
      for (final n in recent) {
        final preview = n.content.length > 40 ? "${n.content.substring(0, 40)}..." : n.content;
        buffer.writeln("• **${n.title}** [${n.tag}]: \"$preview\"");
      }
    }

    return buffer.toString();
  }

  static String _generateEventsResponse(LifeOSContextData ctx) {
    if (ctx.events.isEmpty) {
      return "📅 You have no scheduled calendar events currently.";
    }

    final now = DateTime.now();
    final upcoming = ctx.events.where((e) => e.endTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (upcoming.isEmpty) {
      return "📅 You have no upcoming events scheduled for the rest of today or this week.";
    }

    final buffer = StringBuffer();
    buffer.writeln("📅 **Upcoming Calendar Events:**\n");
    for (final e in upcoming.take(5)) {
      final loc = e.location.isNotEmpty ? " @ ${e.location}" : "";
      buffer.writeln("• **${e.title}**$loc");
      buffer.writeln("  Time: ${_formatDate(e.startTime)} ${_formatHour(e.startTime)} - ${_formatHour(e.endTime)}");
    }
    return buffer.toString();
  }

  static String _generateOverviewResponse(LifeOSContextData ctx) {
    final pendingTasksCount = ctx.tasks.where((t) => !t.isCompleted).length;
    final activeGoalsCount = ctx.goals.where((g) => !g.isAchieved).length;
    final upcomingExamsCount = ctx.studyExams.where((e) => !e.isCompleted && e.daysRemaining >= 0).length;

    final now = DateTime.now();
    final monthlyExpenses = ctx.transactions
        .where((t) => !t.isIncome && t.date.year == now.year && t.date.month == now.month)
        .fold<double>(0.0, (s, t) => s + t.amount);

    return "🌟 **OSLife Snapshot:**\n\n"
        "• 📋 **Tasks**: $pendingTasksCount pending items\n"
        "• 🎯 **Goals**: $activeGoalsCount active goals in progress\n"
        "• 💰 **Expenses**: \$${monthlyExpenses.toStringAsFixed(2)} spent this month\n"
        "• 📚 **Academics**: $upcomingExamsCount upcoming exam(s)\n"
        "• 📝 **Notes**: ${ctx.notes.length} saved notes\n\n"
        "How would you like to proceed? Ask me for details on any of these areas!";
  }

  static String _generateSmartFallback(String rawPrompt, LifeOSContextData ctx) {
    final query = rawPrompt.toLowerCase();

    // Check if query mentions a specific task title
    final matchingTask = ctx.tasks.where((t) => query.contains(t.title.toLowerCase())).toList();
    if (matchingTask.isNotEmpty) {
      final t = matchingTask.first;
      return "📋 Found task matching your query:\n\n"
          "• **${t.title}**\n"
          "• Priority: ${t.priority}\n"
          "• Status: ${t.isCompleted ? 'Completed ✅' : 'Pending ⏳'}\n"
          "• Due: ${_formatDate(t.dueDate)}";
    }

    // Check if query mentions a goal
    final matchingGoal = ctx.goals.where((g) => query.contains(g.title.toLowerCase())).toList();
    if (matchingGoal.isNotEmpty) {
      final g = matchingGoal.first;
      return "🎯 Found goal matching your query:\n\n"
          "• **${g.title}**\n"
          "• Category: ${g.category}\n"
          "• Progress: ${(g.calculatedProgress * 100).toInt()}%\n"
          "• Target Date: ${_formatDate(g.targetDate)}";
    }

    // Check if query mentions a study subject
    final matchingSubj = ctx.studySubjects.where((s) => query.contains(s.name.toLowerCase()) || query.contains(s.code.toLowerCase())).toList();
    if (matchingSubj.isNotEmpty) {
      final s = matchingSubj.first;
      return "📚 Subject details for **${s.name}** (${s.code}):\n\n"
          "• Instructor: ${s.instructor}\n"
          "• Study Hours: ${s.completedHoursThisWeek}h / ${s.targetHoursPerWeek}h target this week";
    }

    return "I've analyzed your query with your local OSLife context. While I couldn't find an exact match for '$rawPrompt', here is what I can help you with:\n\n"
        "• **'What should I do today?'** — Daily schedule & top priorities\n"
        "• **'Show my pending tasks'** — All pending tasks with priority\n"
        "• **'How much did I spend this month?'** — Monthly budget & outflows\n"
        "• **'What are my current goals?'** — Goal milestone tracking\n"
        "• **'Help me plan my study time'** — Upcoming exams & study hours";
  }

  // --- Helpers ---
  static String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[dt.month - 1]} ${dt.day}";
  }

  static String _formatHour(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return "$h12:$minute $ampm";
  }

  static String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[(month - 1) % 12];
  }

  static String daysText(int days) {
    if (days == 0) return "due today";
    if (days == 1) return "due tomorrow";
    return "in $days days";
  }
}
