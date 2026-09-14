import 'package:flutter/material.dart';

enum SearchModuleType {
  task('Tasks', Icons.check_circle_outline, Color(0xFF7C3AED), '/tasks'),
  note('Notes', Icons.description_outlined, Color(0xFF00A2E6), '/notes'),
  event('Calendar Events', Icons.event_outlined, Color(0xFF10B981), '/calendar'),
  expense('Expenses', Icons.account_balance_wallet_outlined, Color(0xFFF59E0B), '/expense'),
  goal('Goals', Icons.flag_outlined, Color(0xFFEF4444), '/goals'),
  study('Study Planner', Icons.school_outlined, Color(0xFF8B5CF6), '/study');

  final String label;
  final IconData icon;
  final Color color;
  final String defaultRoute;

  const SearchModuleType(this.label, this.icon, this.color, this.defaultRoute);
}

class SearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final SearchModuleType moduleType;
  final String route;
  final dynamic rawObject;
  final DateTime? date;

  SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.moduleType,
    required this.route,
    this.rawObject,
    this.date,
  });
}
