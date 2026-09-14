import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';
import '../../models/global_search_model.dart';
import '../../providers/global_search_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/study_provider.dart';

class GlobalSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const GlobalSearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        Provider.of<GlobalSearchProvider>(context, listen: false).setQuery(widget.initialQuery!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<GlobalSearchProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final noteProvider = Provider.of<NoteProvider>(context);
    final calendarProvider = Provider.of<CalendarProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);

    final results = searchProvider.performSearch(
      taskProvider: taskProvider,
      noteProvider: noteProvider,
      calendarProvider: calendarProvider,
      expenseProvider: expenseProvider,
      goalProvider: goalProvider,
      studyProvider: studyProvider,
    );

    final groupedResults = searchProvider.getGroupedResults(results);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletMaxWidth;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Header
            _buildSearchHeader(context, searchProvider),

            // Module Category Filter Chips
            _buildFilterChips(searchProvider),

            const Divider(height: 1, color: AppColors.outlineVariant),

            // Main Results Body
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? AppConstants.paddingDesktop : AppConstants.paddingMobile,
                ),
                child: searchProvider.query.trim().isEmpty
                    ? _buildInitialSuggestions(context, searchProvider)
                    : results.isEmpty
                        ? _buildEmptyResultsState(searchProvider.query)
                        : _buildSearchResultsList(groupedResults, results.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, GlobalSearchProvider searchProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go('/home');
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              borderRadius: 16,
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      autofocus: widget.initialQuery == null || widget.initialQuery!.isEmpty,
                      onChanged: (val) {
                        searchProvider.setQuery(val);
                      },
                      style: const TextStyle(fontSize: 15, color: AppColors.onSurface),
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
                        _searchController.clear();
                        searchProvider.clearQuery();
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(GlobalSearchProvider searchProvider) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: GlobalSearchProvider.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = GlobalSearchProvider.categories[index];
          final isSelected = searchProvider.selectedCategoryFilter == category;
          return FilterChip(
            selected: isSelected,
            label: Text(category),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            backgroundColor: AppColors.surfaceContainerHigh,
            selectedColor: AppColors.primaryContainer,
            checkmarkColor: AppColors.onPrimaryContainer,
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
            onSelected: (selected) {
              if (selected) {
                searchProvider.setCategoryFilter(category);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildInitialSuggestions(BuildContext context, GlobalSearchProvider searchProvider) {
    final suggestions = ['Meeting', 'Design', 'Flutter', 'Salary', 'Groceries', 'Exam', 'Marathon', 'AI'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((tag) {
              return ActionChip(
                avatar: const Icon(Icons.north_west_rounded, size: 14, color: AppColors.primary),
                label: Text(tag),
                labelStyle: const TextStyle(color: AppColors.onSurface, fontSize: 13),
                backgroundColor: AppColors.surfaceContainerHigh,
                side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                onPressed: () {
                  _searchController.text = tag;
                  searchProvider.setQuery(tag);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text(
            'Search Across Modules',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: SearchModuleType.values.map((mod) {
              return GlassCard(
                onTap: () {
                  searchProvider.setCategoryFilter(mod.label.split(' ').first);
                  _focusNode.requestFocus();
                },
                padding: const EdgeInsets.all(12),
                borderRadius: 14,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: mod.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(mod.icon, color: mod.color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        mod.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$query"',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try checking spelling or search using different keywords.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList(
    Map<SearchModuleType, List<SearchResultItem>> groupedResults,
    int totalCount,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Found $totalCount matching result${totalCount == 1 ? "" : "s"}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        ...groupedResults.entries.map((entry) {
          final modType = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(modType.icon, size: 18, color: modType.color),
                    const SizedBox(width: 8),
                    Text(
                      '${modType.label} (${items.length})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: modType.color,
                      ),
                    ),
                  ],
                ),
              ),
              // Items List in Group
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    onTap: () {
                      context.push(item.route);
                    },
                    padding: const EdgeInsets.all(14),
                    borderRadius: 14,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: modType.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(modType.icon, color: modType.color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }
}
