import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense_model.dart';
import '../../utils/currency_formatter.dart';

// ════════════════════════════════════════════════════════════
//  Constants
// ════════════════════════════════════════════════════════════

const _kExpenseCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Entertainment',
  'Health',
  'Utilities',
  'Tech',
  'Housing',
  'Education',
  'Other',
];

const _kIncomeCategories = [
  'Salary',
  'Freelance',
  'Investments',
  'Business',
  'Gift',
  'Other',
];

const _kPaymentMethods = [
  'Credit Card',
  'Debit Card',
  'Cash',
  'Bank Transfer',
  'PayPal',
  'UPI',
];

// Category → color mapping
final Map<String, Color> _categoryColors = {
  'Food': const Color(0xFFF97316),
  'Transport': const Color(0xFF3B82F6),
  'Shopping': const Color(0xFFEC4899),
  'Entertainment': const Color(0xFFA855F7),
  'Health': const Color(0xFF10B981),
  'Utilities': const Color(0xFFEAB308),
  'Tech': const Color(0xFF06B6D4),
  'Housing': const Color(0xFF8B5CF6),
  'Education': const Color(0xFF14B8A6),
  'Other': const Color(0xFF6B7280),
  'Salary': const Color(0xFF22C55E),
  'Freelance': const Color(0xFF84CC16),
  'Investments': const Color(0xFF0EA5E9),
  'Business': const Color(0xFFF59E0B),
  'Gift': const Color(0xFFEC4899),
};

Color _colorForCategory(String cat) =>
    _categoryColors[cat] ?? const Color(0xFF6B7280);

// ════════════════════════════════════════════════════════════
//  Main Screen
// ════════════════════════════════════════════════════════════

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _searchQuery = '';
  String _activeFilter = 'All'; // All | Income | Expense | <category>
  int _touchedPieIndex = -1;
  bool _showPieChart = true; // toggle pie ↔ bar

  final List<String> _filterChips = [
    'All',
    'Income',
    'Expense',
    'Food',
    'Transport',
    'Shopping',
    'Health',
    'Tech',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────
  List<ExpenseModel> _filtered(List<ExpenseModel> all) {
    var list = all;
    if (_activeFilter == 'Income') list = list.where((t) => t.isIncome).toList();
    if (_activeFilter == 'Expense') list = list.where((t) => !t.isIncome).toList();
    if (_activeFilter != 'All' &&
        _activeFilter != 'Income' &&
        _activeFilter != 'Expense') {
      list = list.where((t) => t.category == _activeFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.category.toLowerCase().contains(q) ||
              t.note.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final isWide = MediaQuery.of(context).size.width > 720;
    final filtered = _filtered(provider.transactions);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: 8,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Summary cards ──────────────────────────────────────
                  _SummaryRow(provider: provider),
                  const SizedBox(height: 24),

                  // ── Search bar ────────────────────────────────────────
                  _buildSearchBar(),
                  const SizedBox(height: 12),

                  // ── Filter chips ──────────────────────────────────────
                  _buildFilterChips(),
                  const SizedBox(height: 24),

                  // ── Analytics section ─────────────────────────────────
                  _AnalyticsSection(
                    provider: provider,
                    showPie: _showPieChart,
                    touchedPieIndex: _touchedPieIndex,
                    onToggleChart: () =>
                        setState(() => _showPieChart = !_showPieChart),
                    onPieTouched: (i) =>
                        setState(() => _touchedPieIndex = i),
                  ),
                  const SizedBox(height: 24),

                  // ── Recent transactions ───────────────────────────────
                  _TransactionList(
                    transactions: filtered,
                    onEdit: (t) => _openTransactionModal(context, existing: t),
                    onDelete: (t) => _confirmDelete(context, t, provider),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // ── AppBar ────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              'Expense Tracker',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.onSurface),
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search transactions…',
          hintStyle:
              TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.onSurfaceVariant),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterChips.map((f) {
          final active = _activeFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? AppColors.primaryContainer
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w400,
                    color: active
                        ? Colors.white
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _openTransactionModal(context),
      backgroundColor: AppColors.primaryContainer,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add Transaction',
          style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  // ── Modals ────────────────────────────────────────────────
  void _openTransactionModal(BuildContext context, {ExpenseModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TransactionModal(
        existing: existing,
        onSave: (data) {
          final provider = context.read<ExpenseProvider>();
          if (existing == null) {
            provider.addTransaction(
              title: data['title'],
              amount: data['amount'],
              category: data['category'],
              date: data['date'],
              isIncome: data['isIncome'],
              paymentMethod: data['paymentMethod'],
              note: data['note'],
            );
          } else {
            provider.updateTransaction(existing.copyWith(
              title: data['title'],
              amount: data['amount'],
              category: data['category'],
              date: data['date'],
              isIncome: data['isIncome'],
              paymentMethod: data['paymentMethod'],
              note: data['note'],
            ));
          }
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ExpenseModel t, ExpenseProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction',
            style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "${t.title}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorContainer),
            onPressed: () {
              provider.deleteTransaction(t.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Summary Row (Balance, Income, Expense)
// ════════════════════════════════════════════════════════════

class _SummaryRow extends StatelessWidget {
  final ExpenseProvider provider;
  const _SummaryRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final balance = provider.netBalance;
    final isWide = MediaQuery.of(context).size.width > 720;

    // Full-width balance card
    final balanceCard = GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NET BALANCE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.formatUSD(balance.abs()),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: balance >= 0
                          ? const Color(0xFF10B981)
                          : AppColors.error,
                    ),
                  ),
                  Text(
                    balance >= 0 ? 'You\'re in the green 🎉' : 'Over budget ⚠️',
                    style: TextStyle(
                      fontSize: 13,
                      color: balance >= 0
                          ? const Color(0xFF10B981)
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: balance >= 0
                        ? [
                            const Color(0xFF10B981).withValues(alpha: 0.3),
                            const Color(0xFF059669).withValues(alpha: 0.1),
                          ]
                        : [
                            AppColors.errorContainer.withValues(alpha: 0.3),
                            AppColors.error.withValues(alpha: 0.1),
                          ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  balance >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 32,
                  color: balance >= 0
                      ? const Color(0xFF10B981)
                      : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Savings bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Savings Rate',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.onSurfaceVariant)),
                  Text(
                    provider.totalIncome > 0
                        ? '${((provider.netBalance / provider.totalIncome) * 100).clamp(0, 100).toStringAsFixed(1)}%'
                        : '0%',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: provider.totalIncome > 0
                      ? (provider.netBalance / provider.totalIncome).clamp(0.0, 1.0)
                      : 0,
                  backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final incomeCard = _MiniSummaryCard(
      label: 'INCOME',
      amount: provider.totalIncome,
      icon: Icons.arrow_downward_rounded,
      color: const Color(0xFF10B981),
    );
    final expenseCard = _MiniSummaryCard(
      label: 'EXPENSES',
      amount: provider.totalExpenses,
      icon: Icons.arrow_upward_rounded,
      color: AppColors.error,
    );

    return Column(
      children: [
        balanceCard,
        const SizedBox(height: 12),
        if (isWide)
          Row(children: [
            Expanded(child: incomeCard),
            const SizedBox(width: 12),
            Expanded(child: expenseCard),
          ])
        else
          Row(children: [
            Expanded(child: incomeCard),
            const SizedBox(width: 12),
            Expanded(child: expenseCard),
          ]),
      ],
    );
  }
}

class _MiniSummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _MiniSummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.formatCompact(amount),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Analytics Section (Pie + Bar)
// ════════════════════════════════════════════════════════════

class _AnalyticsSection extends StatelessWidget {
  final ExpenseProvider provider;
  final bool showPie;
  final int touchedPieIndex;
  final VoidCallback onToggleChart;
  final ValueChanged<int> onPieTouched;

  const _AnalyticsSection({
    required this.provider,
    required this.showPie,
    required this.touchedPieIndex,
    required this.onToggleChart,
    required this.onPieTouched,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 720;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface),
            ),
            GestureDetector(
              onTap: onToggleChart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        showPie
                            ? Icons.bar_chart_rounded
                            : Icons.pie_chart_rounded,
                        size: 16,
                        color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      showPie ? 'Bar Chart' : 'Pie Chart',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: showPie
                      ? _PieChartCard(
                          provider: provider,
                          touchedIndex: touchedPieIndex,
                          onTouch: onPieTouched,
                        )
                      : _BarChartCard(provider: provider)),
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryBreakdownCard(provider: provider),
              ),
            ],
          )
        else
          Column(
            children: [
              showPie
                  ? _PieChartCard(
                      provider: provider,
                      touchedIndex: touchedPieIndex,
                      onTouch: onPieTouched,
                    )
                  : _BarChartCard(provider: provider),
              const SizedBox(height: 12),
              _CategoryBreakdownCard(provider: provider),
            ],
          ),
      ],
    );
  }
}

// ── Pie Chart ─────────────────────────────────────────────

class _PieChartCard extends StatelessWidget {
  final ExpenseProvider provider;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _PieChartCard({
    required this.provider,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final breakdown = provider.categoryBreakdown;
    if (breakdown.isEmpty) {
      return const _EmptyChartCard(message: 'No expense data yet');
    }
    final entries = breakdown.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Spending by Category',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent) {
                      onTouch(response?.touchedSection?.touchedSectionIndex ?? -1);
                    }
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final cat = entry.value.key;
                  final val = entry.value.value;
                  final isTouched = i == touchedIndex;
                  return PieChartSectionData(
                    color: _colorForCategory(cat),
                    value: val,
                    title: isTouched
                        ? '${((val / total) * 100).toStringAsFixed(1)}%'
                        : '',
                    radius: isTouched ? 60 : 50,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bar Chart ─────────────────────────────────────────────

class _BarChartCard extends StatelessWidget {
  final ExpenseProvider provider;

  const _BarChartCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.last6MonthsData;
    final maxVal = data.fold<double>(
        0,
        (m, d) => math.max(
            m, math.max(d['income'] as double, d['expenses'] as double)));

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Overview',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface)),
              Row(
                children: [
                  _LegendDot(color: Color(0xFF10B981), label: 'Income'),
                  SizedBox(width: 10),
                  _LegendDot(
                      color: AppColors.error, label: 'Expenses'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.surfaceContainerHighest,
                    getTooltipItem: (group, gi, rod, ri) {
                      final m = data[group.x];
                      final label = ri == 0 ? 'Income' : 'Expenses';
                      final val = ri == 0
                          ? m['income'] as double
                          : m['expenses'] as double;
                      return BarTooltipItem(
                        '$label\n${CurrencyFormatter.formatCompact(val)}',
                        const TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      getTitlesWidget: (val, meta) => Text(
                        CurrencyFormatter.formatCompact(val),
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            data[idx]['label'] as String,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final i = entry.key;
                  final m = entry.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: (m['income'] as double),
                        color: const Color(0xFF10B981),
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: (m['expenses'] as double),
                        color: AppColors.error,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

// ── Category Breakdown List ────────────────────────────────

class _CategoryBreakdownCard extends StatelessWidget {
  final ExpenseProvider provider;
  const _CategoryBreakdownCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final breakdown = provider.categoryBreakdown;
    final total = provider.totalExpenses;
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category Breakdown',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface)),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No data',
                    style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            )
          else
            ...sorted.take(6).map((entry) {
              final pct = total > 0 ? entry.value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _colorForCategory(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(entry.key,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.onSurface)),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                '${(pct * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant)),
                            const SizedBox(width: 8),
                            Text(
                                CurrencyFormatter.formatCompact(entry.value),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct.toDouble(),
                        minHeight: 6,
                        backgroundColor:
                            AppColors.outlineVariant.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(
                            _colorForCategory(entry.key)),
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
}

// ════════════════════════════════════════════════════════════
//  Transaction List
// ════════════════════════════════════════════════════════════

class _TransactionList extends StatelessWidget {
  final List<ExpenseModel> transactions;
  final void Function(ExpenseModel) onEdit;
  final void Function(ExpenseModel) onDelete;

  const _TransactionList({
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface),
            ),
            Text(
              '${transactions.length} records',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const _EmptyTransactions()
        else
          ...transactions.map((t) => _TransactionTile(
                transaction: t,
                onEdit: () => onEdit(t),
                onDelete: () => onDelete(t),
              )),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final ExpenseModel transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final color =
        t.isIncome ? const Color(0xFF10B981) : AppColors.error;
    final sign = t.isIncome ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _colorForCategory(t.category).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  _iconForCategory(t.category, t.isIncome),
                  color: _colorForCategory(t.category),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title & meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _Chip(label: t.category, color: _colorForCategory(t.category)),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d').format(t.date),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                      if (t.paymentMethod.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '· ${t.paymentMethod}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${CurrencyFormatter.formatUSD(t.amount)}',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(Icons.edit_rounded,
                          size: 16, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline_rounded,
                          size: 16, color: AppColors.error),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String cat, bool isIncome) {
    if (isIncome) {
      switch (cat) {
        case 'Salary': return Icons.work_outline_rounded;
        case 'Freelance': return Icons.laptop_rounded;
        case 'Investments': return Icons.trending_up_rounded;
        case 'Business': return Icons.store_rounded;
        default: return Icons.attach_money_rounded;
      }
    }
    switch (cat) {
      case 'Food': return Icons.restaurant_rounded;
      case 'Transport': return Icons.directions_car_rounded;
      case 'Shopping': return Icons.shopping_bag_outlined;
      case 'Entertainment': return Icons.movie_rounded;
      case 'Health': return Icons.favorite_outline_rounded;
      case 'Utilities': return Icons.bolt_rounded;
      case 'Tech': return Icons.computer_rounded;
      case 'Housing': return Icons.home_outlined;
      case 'Education': return Icons.school_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 48,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text('No transactions found',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            const Text('Tap + to add your first transaction',
                style: TextStyle(
                    fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _EmptyChartCard extends StatelessWidget {
  final String message;
  const _EmptyChartCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Text(message,
            style: const TextStyle(color: AppColors.onSurfaceVariant)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Add / Edit Transaction Modal
// ════════════════════════════════════════════════════════════

class _TransactionModal extends StatefulWidget {
  final ExpenseModel? existing;
  final void Function(Map<String, dynamic>) onSave;

  const _TransactionModal({this.existing, required this.onSave});

  @override
  State<_TransactionModal> createState() => _TransactionModalState();
}

class _TransactionModalState extends State<_TransactionModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;

  bool _isIncome = false;
  String _category = 'Food';
  String _paymentMethod = 'Credit Card';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _isIncome = e?.isIncome ?? false;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _amountCtrl =
        TextEditingController(text: e != null ? e.amount.toString() : '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? (_isIncome ? 'Salary' : 'Food');
    _paymentMethod = e?.paymentMethod ?? 'Credit Card';
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryContainer,
            onPrimary: Colors.white,
            surface: AppColors.surfaceContainerHigh,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'title': _titleCtrl.text.trim(),
      'amount': double.tryParse(_amountCtrl.text.trim()) ?? 0,
      'category': _category,
      'date': _date,
      'isIncome': _isIncome,
      'paymentMethod': _paymentMethod,
      'note': _noteCtrl.text.trim(),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cats = _isIncome ? _kIncomeCategories : _kExpenseCategories;
    if (!cats.contains(_category)) {
      _category = cats.first;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        AppColors.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existing == null
                          ? 'Add Transaction'
                          : 'Edit Transaction',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.onSurfaceVariant),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.outlineVariant, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Income / Expense toggle
                        _buildTypeToggle(),
                        const SizedBox(height: 20),

                        // Title
                        _buildLabel('Title'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _titleCtrl,
                          hint: 'e.g. Grocery Shopping',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Amount
                        _buildLabel('Amount'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _amountCtrl,
                          hint: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          prefix: const Text('\$  ',
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.bold)),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Amount is required';
                            if (double.tryParse(v) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category
                        _buildLabel('Category'),
                        const SizedBox(height: 8),
                        _buildCategorySelector(cats),
                        const SizedBox(height: 16),

                        // Date
                        _buildLabel('Date'),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 18,
                                    color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 10),
                                Text(
                                  DateFormat('MMMM d, yyyy').format(_date),
                                  style: const TextStyle(
                                      color: AppColors.onSurface),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Payment method
                        _buildLabel('Payment Method'),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _paymentMethod,
                          items: _kPaymentMethods,
                          onChanged: (v) =>
                              setState(() => _paymentMethod = v!),
                        ),
                        const SizedBox(height: 16),

                        // Note
                        _buildLabel('Note (optional)'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _noteCtrl,
                          hint: 'Add a note…',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: _isIncome
                                  ? const Color(0xFF10B981)
                                  : AppColors.primaryContainer,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              widget.existing == null
                                  ? (_isIncome
                                      ? 'Add Income'
                                      : 'Add Expense')
                                  : 'Save Changes',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isIncome = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isIncome
                      ? AppColors.error.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: !_isIncome
                      ? Border.all(
                          color: AppColors.error.withValues(alpha: 0.5))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward_rounded,
                        size: 16,
                        color: !_isIncome
                            ? AppColors.error
                            : AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Expense',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: !_isIncome
                              ? AppColors.error
                              : AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isIncome = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isIncome
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: _isIncome
                      ? Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.5))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_downward_rounded,
                        size: 16,
                        color: _isIncome
                            ? const Color(0xFF10B981)
                            : AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Income',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isIncome
                              ? const Color(0xFF10B981)
                              : AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? prefix,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
        prefix: prefix,
        filled: true,
        fillColor: AppColors.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryContainer),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCategorySelector(List<String> cats) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cats.map((cat) {
        final selected = _category == cat;
        final color = _colorForCategory(cat);
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.2)
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? color.withValues(alpha: 0.7)
                    : AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              cat,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? color : AppColors.onSurfaceVariant),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surfaceContainerHighest,
          style: const TextStyle(color: AppColors.onSurface),
          icon: const Icon(Icons.expand_more_rounded,
              color: AppColors.onSurfaceVariant),
          items: items
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
