import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/task_tile.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../widgets/reminder_dropdown.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Pending', 'Completed', 'High Priority', 'Today'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter helper logic
  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    final query = _searchController.text.trim().toLowerCase();
    final now = DateTime.now();

    return tasks.where((task) {
      // Search matching
      final matchesQuery = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.category.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      // Filter matching
      switch (_selectedFilter) {
        case 'Pending':
          return !task.isCompleted;
        case 'Completed':
          return task.isCompleted;
        case 'High Priority':
          return task.priority == 'High';
        case 'Today':
          return task.dueDate.year == now.year &&
              task.dueDate.month == now.month &&
              task.dueDate.day == now.day;
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final allTasks = taskProvider.tasks;
    final filteredTasks = _getFilteredTasks(allTasks);

    // Calculate Statistics
    final totalCount = allTasks.length;
    final completedCount = allTasks.where((t) => t.isCompleted).length;
    final pendingCount = totalCount - completedCount;
    final completionPct = totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Task Manager',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: AppColors.surfaceContainerLow,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Tasks',
            onPressed: () => taskProvider.loadTasks(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditTaskModal(context, taskProvider: taskProvider),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded, size: 20),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
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
                // Section 1: Task Statistics Cards
                _buildStatisticsSection(totalCount, completedCount, pendingCount, completionPct, isDesktop),
                const SizedBox(height: 24),

                // Section 2: Search Bar & Filters
                _buildSearchAndFiltersSection(context),
                const SizedBox(height: 24),

                // Section 3: Task List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_selectedFilter Tasks (${filteredTasks.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (_selectedFilter != 'All' || _searchController.text.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'All';
                            _searchController.clear();
                          });
                        },
                        icon: const Icon(Icons.filter_list_off_rounded, size: 16),
                        label: const Text('Reset Filters'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Section 4: Task List
                if (filteredTasks.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskTile(
                        task: task,
                        onToggle: (_) => taskProvider.toggleTask(task.id),
                        onEdit: () => _showAddOrEditTaskModal(context, taskProvider: taskProvider, existingTask: task),
                        onDelete: () => _showDeleteConfirmationDialog(context, taskProvider, task),
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Task Statistics Cards
  Widget _buildStatisticsSection(int total, int completed, int pending, int completionPct, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isDesktop
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(
              width: cardWidth,
              title: 'TOTAL TASKS',
              value: '$total',
              subtitle: 'Current workload',
              icon: Icons.format_list_bulleted_rounded,
              color: AppColors.primary,
            ),
            _buildStatCard(
              width: cardWidth,
              title: 'COMPLETED',
              value: '$completed',
              subtitle: '$completionPct% achieved',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
            ),
            _buildStatCard(
              width: cardWidth,
              title: 'PENDING',
              value: '$pending',
              subtitle: 'Requires action',
              icon: Icons.pending_actions_rounded,
              color: AppColors.tertiary,
            ),
            _buildStatCard(
              width: cardWidth,
              title: 'COMPLETION RATE',
              value: '$completionPct%',
              subtitle: 'Progress metric',
              icon: Icons.donut_large_rounded,
              color: AppColors.secondary,
              progressValue: completionPct / 100.0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    double? progressValue,
  }) {
    return SizedBox(
      width: width,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 18,
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            if (progressValue != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressValue.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Search & Filters Bar
  Widget _buildSearchAndFiltersSection(BuildContext context) {
    final filters = ['All', 'Pending', 'Completed', 'High Priority', 'Today'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Bar
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: 16,
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'Search tasks by title or category...',
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
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    }
                  },
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 3. Empty State Widget
  Widget _buildEmptyState() {
    return const GlassCard(
      padding: EdgeInsets.all(32),
      borderRadius: 20,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.task_alt_rounded, size: 48, color: AppColors.onSurfaceVariant),
            SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            SizedBox(height: 6),
            Text(
              'Try adjusting your search query or filter settings.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 4. Add or Edit Task Modal
  void _showAddOrEditTaskModal(BuildContext context, {required TaskProvider taskProvider, TaskModel? existingTask}) {
    final isEditing = existingTask != null;
    final titleController = TextEditingController(text: existingTask?.title ?? '');
    String selectedCategory = existingTask?.category ?? 'Work';
    String selectedPriority = existingTask?.priority ?? 'Medium';
    DateTime selectedDate = existingTask?.dueDate ?? DateTime.now();
    int? selectedReminder = existingTask?.reminderMinutesBefore;

    final categories = ['Work', 'Design', 'Meeting', 'Health', 'Personal', 'Engineering'];
    final priorities = ['High', 'Medium', 'Low'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
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
                  Text(
                    isEditing ? 'Edit Task' : 'Create New Task',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Title Input
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'e.g. Complete Flutter clean architecture',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Category Selector
                  const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              selectedCategory = cat;
                            });
                          }
                        },
                        selectedColor: AppColors.primaryContainer,
                        backgroundColor: AppColors.surfaceContainerLow,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  // Priority Selector
                  const Text('Priority Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    children: priorities.map((p) {
                      final isSelected = selectedPriority == p;
                      Color pColor = p == 'High' ? const Color(0xFFEF4444) : (p == 'Medium' ? AppColors.primary : AppColors.secondary);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedPriority = p;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? pColor.withValues(alpha: 0.2) : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? pColor : AppColors.outlineVariant.withValues(alpha: 0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  p,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? pColor : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  // Due Date Selection Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Due Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: const Text('Change Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Reminder Selector
                  ReminderDropdown(
                    value: selectedReminder,
                    onChanged: (v) => setModalState(() => selectedReminder = v),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final text = titleController.text.trim();
                              if (text.isNotEmpty) {
                                if (isEditing) {
                                  taskProvider.updateTask(existingTask.id, text, selectedCategory, selectedPriority, selectedDate, reminderMinutesBefore: selectedReminder);
                                } else {
                                  taskProvider.addTask(text, selectedCategory, selectedPriority, dueDate: selectedDate, reminderMinutesBefore: selectedReminder);
                                }
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(isEditing ? 'Save Changes' : 'Create Task', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 5. Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(BuildContext context, TaskProvider taskProvider, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
              SizedBox(width: 10),
              Text('Delete Task', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${task.title}"?\nThis action cannot be undone.',
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                taskProvider.deleteTask(task.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted task "${task.title}"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorContainer,
                foregroundColor: AppColors.onErrorContainer,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
