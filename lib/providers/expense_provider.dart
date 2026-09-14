import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/hive_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final String _uid;
  List<ExpenseModel> _transactions = [];
  final bool _isLoading = false;

  ExpenseProvider({required String uid}) : _uid = uid {
    _loadInitialData();
  }

  List<ExpenseModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  void _loadInitialData() {
    // New users start with empty expenses — no sample data.
    if (HiveService.isUserBoxEmpty(HiveService.expensesBoxName, _uid)) {
      _transactions = [];
    } else {
      _transactions = HiveService.getUserItems(
        HiveService.expensesBoxName,
        _uid,
        (map) => ExpenseModel.fromMap(map),
      );
    }
  }

  // ── Keep legacy getter so Dashboard still compiles ──────────────────────────
  List<ExpenseModel> get expenses =>
      _transactions.where((t) => !t.isIncome).toList();

  double get totalWeeklySpend {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _transactions
        .where((t) => !t.isIncome && t.date.isAfter(weekAgo))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // ── Summary getters ─────────────────────────────────────────────────────────
  double get totalIncome =>
      _transactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get totalExpenses =>
      _transactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get netBalance => totalIncome - totalExpenses;

  // ── Monthly bar-chart data (last 6 months) ──────────────────────────────────
  List<Map<String, dynamic>> get last6MonthsData {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final income = _transactions
          .where((t) =>
              t.isIncome &&
              t.date.year == month.year &&
              t.date.month == month.month)
          .fold(0.0, (s, t) => s + t.amount);
      final expenses = _transactions
          .where((t) =>
              !t.isIncome &&
              t.date.year == month.year &&
              t.date.month == month.month)
          .fold(0.0, (s, t) => s + t.amount);
      result.add({
        'label': _shortMonth(month.month),
        'income': income,
        'expenses': expenses,
      });
    }
    return result;
  }

  // ── Category breakdown for pie chart ────────────────────────────────────────
  Map<String, double> get categoryBreakdown {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────────
  void addTransaction({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required bool isIncome,
    String paymentMethod = 'Cash',
    String note = '',
  }) {
    final t = ExpenseModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      category: category,
      date: date,
      paymentMethod: paymentMethod,
      isIncome: isIncome,
      note: note,
    );
    _transactions.insert(0, t);
    HiveService.saveUserItem(HiveService.expensesBoxName, _uid, t.id, t.toMap());
    notifyListeners();
  }

  void updateTransaction(ExpenseModel updated) {
    final idx = _transactions.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _transactions[idx] = updated;
      HiveService.saveUserItem(HiveService.expensesBoxName, _uid, updated.id, updated.toMap());
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    HiveService.deleteUserItem(HiveService.expensesBoxName, _uid, id);
    notifyListeners();
  }

  // Keep legacy addExpense so older code still compiles
  void addExpense(String title, double amount, String category) {
    addTransaction(
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
      isIncome: false,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String _shortMonth(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(m - 1) % 12];
  }
}
