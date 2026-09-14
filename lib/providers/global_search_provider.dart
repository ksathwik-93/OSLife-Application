import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/global_search_model.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../providers/calendar_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/study_provider.dart';

class GlobalSearchProvider extends ChangeNotifier {
  String _query = '';
  String _selectedCategoryFilter = 'All';

  String get query => _query;
  String get selectedCategoryFilter => _selectedCategoryFilter;

  static const List<String> categories = [
    'All',
    'Tasks',
    'Notes',
    'Events',
    'Expenses',
    'Goals',
    'Study',
  ];

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setCategoryFilter(String cat) {
    _selectedCategoryFilter = cat;
    notifyListeners();
  }

  void clearQuery() {
    _query = '';
    notifyListeners();
  }

  List<SearchResultItem> performSearch({
    required TaskProvider taskProvider,
    required NoteProvider noteProvider,
    required CalendarProvider calendarProvider,
    required ExpenseProvider expenseProvider,
    required GoalProvider goalProvider,
    required StudyProvider studyProvider,
  }) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final results = <SearchResultItem>[];
    final dateFormat = DateFormat('MMM d, yyyy');

    // 1. Search Tasks
    for (final t in taskProvider.tasks) {
      if (t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.priority.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            id: t.id,
            title: t.title,
            subtitle: 'Category: ${t.category} • Priority: ${t.priority} • Due: ${dateFormat.format(t.dueDate)}',
            moduleType: SearchModuleType.task,
            route: '/tasks',
            rawObject: t,
            date: t.dueDate,
          ),
        );
      }
    }

    // 2. Search Notes
    for (final n in noteProvider.notes) {
      if (n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q) ||
          n.tag.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            id: n.id,
            title: n.title,
            subtitle: 'Tag: #${n.tag} • ${n.content}',
            moduleType: SearchModuleType.note,
            route: '/notes',
            rawObject: n,
            date: n.updatedAt,
          ),
        );
      }
    }

    // 3. Search Calendar Events
    for (final e in calendarProvider.events) {
      if (e.title.toLowerCase().contains(q) ||
          e.location.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            id: e.id,
            title: e.title,
            subtitle: 'Location: ${e.location.isEmpty ? "N/A" : e.location} • Category: ${e.category} • ${dateFormat.format(e.startTime)}',
            moduleType: SearchModuleType.event,
            route: '/calendar',
            rawObject: e,
            date: e.startTime,
          ),
        );
      }
    }

    // 4. Search Expenses
    for (final ex in expenseProvider.transactions) {
      if (ex.title.toLowerCase().contains(q) ||
          ex.category.toLowerCase().contains(q) ||
          ex.paymentMethod.toLowerCase().contains(q) ||
          ex.note.toLowerCase().contains(q)) {
        final amountPrefix = ex.isIncome ? '+' : '-';
        results.add(
          SearchResultItem(
            id: ex.id,
            title: ex.title,
            subtitle: '$amountPrefix\$${ex.amount.toStringAsFixed(2)} • Category: ${ex.category} • ${ex.paymentMethod}',
            moduleType: SearchModuleType.expense,
            route: '/expense',
            rawObject: ex,
            date: ex.date,
          ),
        );
      }
    }

    // 5. Search Goals
    for (final g in goalProvider.allGoals) {
      final matchesMilestones = g.milestones.any((m) => m.title.toLowerCase().contains(q));
      if (g.title.toLowerCase().contains(q) ||
          g.description.toLowerCase().contains(q) ||
          g.category.toLowerCase().contains(q) ||
          matchesMilestones) {
        final progressPct = (g.calculatedProgress * 100).toInt();
        results.add(
          SearchResultItem(
            id: g.id,
            title: g.title,
            subtitle: 'Category: ${g.category} • Progress: $progressPct% • Target: ${dateFormat.format(g.targetDate)}',
            moduleType: SearchModuleType.goal,
            route: '/goals',
            rawObject: g,
            date: g.targetDate,
          ),
        );
      }
    }

    // 6. Search Study Planner Items
    for (final s in studyProvider.subjects) {
      if (s.name.toLowerCase().contains(q) ||
          s.code.toLowerCase().contains(q) ||
          s.instructor.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            id: s.id,
            title: s.name,
            subtitle: 'Subject Code: ${s.code} • Instructor: ${s.instructor}',
            moduleType: SearchModuleType.study,
            route: '/study',
            rawObject: s,
          ),
        );
      }
    }

    for (final a in studyProvider.assignments) {
      if (a.title.toLowerCase().contains(q) ||
          a.subjectName.toLowerCase().contains(q) ||
          a.priority.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            id: a.id,
            title: a.title,
            subtitle: 'Assignment (${a.subjectName}) • Due: ${dateFormat.format(a.dueDate)} • Priority: ${a.priority}',
            moduleType: SearchModuleType.study,
            route: '/study',
            rawObject: a,
            date: a.dueDate,
          ),
        );
      }
    }

    for (final ex in studyProvider.exams) {
      if (ex.title.toLowerCase().contains(q) ||
          ex.subjectName.toLowerCase().contains(q) ||
          ex.location.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            id: ex.id,
            title: ex.title,
            subtitle: 'Exam (${ex.subjectName}) • Date: ${dateFormat.format(ex.examDate)} • Location: ${ex.location}',
            moduleType: SearchModuleType.study,
            route: '/study',
            rawObject: ex,
            date: ex.examDate,
          ),
        );
      }
    }

    for (final ss in studyProvider.sessions) {
      if (ss.topic.toLowerCase().contains(q) || ss.subjectName.toLowerCase().contains(q)) {
        results.add(
          SearchResultItem(
            id: ss.id,
            title: ss.topic,
            subtitle: 'Study Session (${ss.subjectName}) • Duration: ${ss.durationMinutes} mins',
            moduleType: SearchModuleType.study,
            route: '/study',
            rawObject: ss,
            date: ss.date,
          ),
        );
      }
    }

    // Apply category filter if active
    if (_selectedCategoryFilter != 'All') {
      return results.where((item) {
        switch (_selectedCategoryFilter) {
          case 'Tasks':
            return item.moduleType == SearchModuleType.task;
          case 'Notes':
            return item.moduleType == SearchModuleType.note;
          case 'Events':
            return item.moduleType == SearchModuleType.event;
          case 'Expenses':
            return item.moduleType == SearchModuleType.expense;
          case 'Goals':
            return item.moduleType == SearchModuleType.goal;
          case 'Study':
            return item.moduleType == SearchModuleType.study;
          default:
            return true;
        }
      }).toList();
    }

    return results;
  }

  Map<SearchModuleType, List<SearchResultItem>> getGroupedResults(List<SearchResultItem> items) {
    final map = <SearchModuleType, List<SearchResultItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.moduleType, () => []).add(item);
    }
    return map;
  }
}
