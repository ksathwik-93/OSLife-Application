import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/event_card.dart';
import '../../widgets/reminder_dropdown.dart';
import '../../providers/calendar_provider.dart';
import '../../models/event_model.dart';
import '../../utils/date_formatter.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  DateTime _displayMonth = DateTime.now();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter logic
  List<EventModel> _getFilteredEvents(List<EventModel> events, DateTime selectedDate) {
    final query = _searchController.text.trim().toLowerCase();

    return events.where((e) {
      final matchesQuery = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          e.location.toLowerCase().contains(query) ||
          e.category.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_selectedCategory != 'All' &&
          e.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      // Date matching if no active search query
      if (query.isEmpty) {
        return e.startTime.year == selectedDate.year &&
            e.startTime.month == selectedDate.month &&
            e.startTime.day == selectedDate.day;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = Provider.of<CalendarProvider>(context);
    final allEvents = calendarProvider.events;
    final selectedDate = calendarProvider.selectedDate;
    final filteredEvents = _getFilteredEvents(allEvents, selectedDate);

    // Compute statistics
    final now = DateTime.now();
    final totalEvents = allEvents.length;
    final todayEvents = allEvents.where((e) =>
        e.startTime.year == now.year &&
        e.startTime.month == now.month &&
        e.startTime.day == now.day).length;

    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final weekEvents = allEvents.where((e) =>
        e.startTime.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        e.startTime.isBefore(endOfWeek)).length;

    final monthEvents = allEvents.where((e) =>
        e.startTime.year == now.year && e.startTime.month == now.month).length;

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Calendar & Schedule',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: AppColors.surfaceContainerLow,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Go to Today',
            onPressed: () {
              final today = DateTime.now();
              setState(() {
                _displayMonth = today;
              });
              calendarProvider.setSelectedDate(today);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload Calendar',
            onPressed: () => calendarProvider.loadEvents(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditEventModal(context, calendarProvider: calendarProvider),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.event_available_rounded, size: 20),
        label: const Text('Add Event', style: TextStyle(fontWeight: FontWeight.bold)),
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
                // Section 1: Statistics Row
                _buildStatisticsSection(totalEvents, todayEvents, weekEvents, monthEvents, isDesktop),
                const SizedBox(height: 24),

                // Responsive Layout Split for Desktop vs Mobile
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Interactive Month Calendar Grid
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildMonthlyCalendarCard(calendarProvider, allEvents),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column: Search, Categories & Daily Agenda List
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchAndFiltersSection(context),
                            const SizedBox(height: 20),
                            _buildAgendaHeader(selectedDate, filteredEvents.length),
                            const SizedBox(height: 14),
                            _buildEventList(filteredEvents, calendarProvider),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Interactive Day Strip Picker for Mobile
                      _buildMobileDayStripPicker(calendarProvider, allEvents),
                      const SizedBox(height: 20),
                      _buildSearchAndFiltersSection(context),
                      const SizedBox(height: 20),
                      _buildAgendaHeader(selectedDate, filteredEvents.length),
                      const SizedBox(height: 14),
                      _buildEventList(filteredEvents, calendarProvider),
                    ],
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Statistics Row
  Widget _buildStatisticsSection(int total, int today, int week, int month, bool isDesktop) {
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
              title: 'TOTAL EVENTS',
              value: '$total',
              subtitle: 'Scheduled events',
              icon: Icons.calendar_month_rounded,
              color: AppColors.primary,
            ),
            _buildStatCard(
              width: cardWidth,
              title: "TODAY'S SCHEDULE",
              value: '$today',
              subtitle: 'Events for today',
              icon: Icons.event_available_rounded,
              color: AppColors.secondary,
            ),
            _buildStatCard(
              width: cardWidth,
              title: 'THIS WEEK',
              value: '$week',
              subtitle: 'Upcoming 7 days',
              icon: Icons.date_range_rounded,
              color: AppColors.tertiary,
            ),
            _buildStatCard(
              width: cardWidth,
              title: 'THIS MONTH',
              value: '$month',
              subtitle: 'Current month total',
              icon: Icons.edit_calendar_rounded,
              color: const Color(0xFF10B981),
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
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Interactive Monthly Calendar Card (Desktop & Mobile view)
  Widget _buildMonthlyCalendarCard(CalendarProvider calendarProvider, List<EventModel> allEvents) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final year = _displayMonth.year;
    final monthName = months[_displayMonth.month - 1];

    final daysInMonth = DateTime(year, _displayMonth.month + 1, 0).day;
    final firstWeekday = DateTime(year, _displayMonth.month, 1).weekday; // 1 = Mon

    final selectedDate = calendarProvider.selectedDate;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        children: [
          // Month Header Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$monthName $year',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.onSurface),
                    onPressed: () {
                      setState(() {
                        _displayMonth = DateTime(year, _displayMonth.month - 1, 1);
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurface),
                    onPressed: () {
                      setState(() {
                        _displayMonth = DateTime(year, _displayMonth.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day Header Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
              return SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 42, // 6 weeks grid
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayNum = dayOffset + 1;
              final cellDate = DateTime(year, _displayMonth.month, dayNum);

              final isSelected = cellDate.year == selectedDate.year &&
                  cellDate.month == selectedDate.month &&
                  cellDate.day == selectedDate.day;

              final isToday = cellDate.year == DateTime.now().year &&
                  cellDate.month == DateTime.now().month &&
                  cellDate.day == DateTime.now().day;

              final hasEvents = allEvents.any((e) =>
                  e.startTime.year == cellDate.year &&
                  e.startTime.month == cellDate.month &&
                  e.startTime.day == cellDate.day);

              return GestureDetector(
                onTap: () => calendarProvider.setSelectedDate(cellDate),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : (isToday ? AppColors.surfaceContainerHigh : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : (isToday ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected || isToday ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      if (hasEvents) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppColors.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Mobile Day Strip Picker
  Widget _buildMobileDayStripPicker(CalendarProvider calendarProvider, List<EventModel> allEvents) {
    final selectedDate = calendarProvider.selectedDate;

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      borderRadius: 18,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(14, (index) {
            final date = DateTime.now().subtract(const Duration(days: 3)).add(Duration(days: index));
            final isSelected = date.year == selectedDate.year &&
                date.month == selectedDate.month &&
                date.day == selectedDate.day;

            final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            final dayLabel = weekdays[date.weekday - 1];

            final hasEvents = allEvents.any((e) =>
                e.startTime.year == date.year &&
                e.startTime.month == date.month &&
                e.startTime.day == date.day);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: InkWell(
                onTap: () => calendarProvider.setSelectedDate(date),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      if (hasEvents) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppColors.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // 3. Search Bar & Category Filters
  Widget _buildSearchAndFiltersSection(BuildContext context) {
    final categories = ['All', 'Work', 'Personal', 'Team', 'Tech', 'Meeting', 'Health'];

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
                    hintText: 'Search events by title, location, or category...',
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
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
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

  // 4. Agenda Header
  Widget _buildAgendaHeader(DateTime selectedDate, int count) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;
    final dateStr = '${DateFormatter.getMonthAbbr(selectedDate)} ${selectedDate.day}, ${selectedDate.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isToday ? 'Today\'s Agenda ($count)' : 'Agenda for $dateStr ($count)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ],
    );
  }

  // 5. Event List or Empty State
  Widget _buildEventList(List<EventModel> events, CalendarProvider calendarProvider) {
    if (events.isEmpty) {
      return const GlassCard(
        padding: EdgeInsets.all(32),
        borderRadius: 20,
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_busy_rounded, size: 48, color: AppColors.onSurfaceVariant),
              SizedBox(height: 16),
              Text(
                'No events scheduled',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              SizedBox(height: 6),
              Text(
                'Tap + Add Event to schedule a new appointment or session.',
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final ev = events[index];
        return EventCard(
          event: ev,
          onEdit: () => _showAddOrEditEventModal(context, calendarProvider: calendarProvider, existingEvent: ev),
          onDelete: () => _showDeleteConfirmationDialog(context, calendarProvider, ev),
        );
      },
    );
  }

  // Create or Edit Event Modal
  void _showAddOrEditEventModal(BuildContext context, {required CalendarProvider calendarProvider, EventModel? existingEvent}) {
    final isEditing = existingEvent != null;
    final titleController = TextEditingController(text: existingEvent?.title ?? '');
    final locationController = TextEditingController(text: existingEvent?.location ?? '');
    String selectedCategory = existingEvent?.category ?? 'Work';

    DateTime eventDate = existingEvent?.startTime ?? calendarProvider.selectedDate;
    TimeOfDay startTime = isEditing ? TimeOfDay.fromDateTime(existingEvent.startTime) : const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay endTime = isEditing ? TimeOfDay.fromDateTime(existingEvent.endTime) : const TimeOfDay(hour: 11, minute: 30);
    int? selectedReminder = existingEvent?.reminderMinutesBefore;

    final categories = ['Work', 'Personal', 'Team', 'Tech', 'Meeting', 'Health'];

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
                    isEditing ? 'Edit Event' : 'Schedule New Event',
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
                    autofocus: !isEditing,
                    style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Event Title',
                      hintText: 'e.g. Neural AI Architecture Review',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Location Input
                  TextField(
                    controller: locationController,
                    style: const TextStyle(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Location / Link',
                      hintText: 'e.g. Google Meet or Conference Room B',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category Selector
                  const Text('Category Tag', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
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
                  const SizedBox(height: 16),
                  // Date & Time Selectors
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: eventDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() {
                                eventDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded, size: 16),
                          label: Text('${eventDate.day}/${eventDate.month}/${eventDate.year}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setModalState(() {
                                startTime = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.access_time_rounded, size: 16),
                          label: Text(startTime.format(context)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setModalState(() {
                                endTime = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.access_time_filled_rounded, size: 16),
                          label: Text(endTime.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                            final title = titleController.text.trim();
                            final location = locationController.text.trim();
                            if (title.isNotEmpty) {
                              final startDT = DateTime(eventDate.year, eventDate.month, eventDate.day, startTime.hour, startTime.minute);
                              final endDT = DateTime(eventDate.year, eventDate.month, eventDate.day, endTime.hour, endTime.minute);

                              if (isEditing) {
                                calendarProvider.updateEvent(existingEvent.id, title, location, startDT, endDT, selectedCategory, reminderMinutesBefore: selectedReminder);
                              } else {
                                calendarProvider.addEvent(title, location, startDT, endDT, selectedCategory, reminderMinutesBefore: selectedReminder);
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
                          child: Text(isEditing ? 'Save Changes' : 'Create Event', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  // Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(BuildContext context, CalendarProvider calendarProvider, EventModel event) {
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
              Text('Delete Event', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${event.title}"?\nThis action cannot be undone.',
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                calendarProvider.deleteEvent(event.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted event "${event.title}"'),
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
