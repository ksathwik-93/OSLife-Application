import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/study_model.dart';
import '../../providers/study_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import 'widgets/study_statistics_section.dart';
import 'widgets/timetable_view.dart';
import 'widgets/assignment_list.dart';
import 'widgets/exam_card_list.dart';
import 'widgets/add_edit_study_dialog.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddStudyDialog(BuildContext context, {StudyDialogMode mode = StudyDialogMode.logSession}) {
    showDialog(
      context: context,
      builder: (context) => AddEditStudyDialog(initialMode: mode),
    );
  }

  void _openEditAssignment(BuildContext context, AssignmentModel assignment) {
    showDialog(
      context: context,
      builder: (context) => AddEditStudyDialog(editAssignment: assignment),
    );
  }

  void _openEditExam(BuildContext context, ExamModel exam) {
    showDialog(
      context: context,
      builder: (context) => AddEditStudyDialog(editExam: exam),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceContainerLow,
            elevation: 0,
            title: const Text(
              'Study Planner & Analytics',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            actions: [
              IconButton(
                tooltip: 'Log Study Session',
                icon: const Icon(Icons.timer_outlined, color: AppColors.secondary, size: 24),
                onPressed: () => _openAddStudyDialog(context, mode: StudyDialogMode.logSession),
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.secondary,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Overview', icon: Icon(Icons.dashboard_outlined, size: 18)),
                Tab(text: 'Timetable', icon: Icon(Icons.calendar_month_outlined, size: 18)),
                Tab(text: 'Assignments', icon: Icon(Icons.assignment_outlined, size: 18)),
                Tab(text: 'Exams', icon: Icon(Icons.school_outlined, size: 18)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAddStudyDialog(context),
            backgroundColor: AppColors.secondaryContainer,
            foregroundColor: AppColors.onSecondaryContainer,
            icon: const Icon(Icons.add),
            label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Overview Dashboard
              _buildOverviewTab(context, provider),

              // Tab 2: Timetable Schedule
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: TimetableView(
                  timetable: provider.timetable,
                  onDeleteSlot: (id) => provider.deleteTimetableSlot(id),
                  onAddSlot: () => _openAddStudyDialog(context, mode: StudyDialogMode.addClassSlot),
                ),
              ),

              // Tab 3: Assignments List
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: AssignmentList(
                  assignments: provider.filteredAssignments,
                  onToggle: (id) => provider.toggleAssignment(id),
                  onEdit: (asgn) => _openEditAssignment(context, asgn),
                  onDelete: (id) => provider.deleteAssignment(id),
                  onAddAssignment: () => _openAddStudyDialog(context, mode: StudyDialogMode.addAssignment),
                ),
              ),

              // Tab 4: Exams & Assessments
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ExamCardList(
                  exams: provider.filteredExams,
                  onToggle: (id) => provider.toggleExamCompletion(id),
                  onEdit: (exam) => _openEditExam(context, exam),
                  onDelete: (id) => provider.deleteExam(id),
                  onAddExam: () => _openAddStudyDialog(context, mode: StudyDialogMode.addExam),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(BuildContext context, StudyProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Statistics Header
          StudyStatisticsSection(
            completedHours: provider.totalWeeklyStudyHours,
            targetHours: provider.targetWeeklyStudyHours,
            progressRatio: provider.weeklyProgressRatio,
            pendingAssignments: provider.pendingAssignmentsCount,
            nextExam: provider.nextUpcomingExam,
          ),
          const SizedBox(height: 20),

          // Course Subjects Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ENROLLED SUBJECTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                '${provider.subjects.length} Active Courses',
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.subjects.length,
            itemBuilder: (context, index) {
              final subject = provider.subjects[index];
              final progress = (subject.completedHoursThisWeek / subject.targetHoursPerWeek).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: subject.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                subject.code,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: subject.color,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${subject.completedHoursThisWeek.toStringAsFixed(1)} / ${subject.targetHoursPerWeek.toStringAsFixed(1)} hrs',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subject.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Instructor: ${subject.instructor}',
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(subject.color),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Recent Logged Study Sessions
          const Text(
            'RECENT STUDY LOGS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 10),

          if (provider.sessions.isEmpty)
            const Text(
              'No study sessions logged yet today.',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.sessions.length,
              itemBuilder: (context, index) {
                final session = provider.sessions[index];
                final formattedDate = DateFormat('MMM dd, hh:mm a').format(session.date);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 18, color: AppColors.secondary),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.subjectName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  '${session.topic} • $formattedDate',
                                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${session.durationMinutes} mins',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

