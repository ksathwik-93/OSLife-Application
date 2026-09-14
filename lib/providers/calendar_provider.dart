import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class CalendarProvider extends ChangeNotifier {
  final String _uid;

  List<EventModel> _events = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  CalendarProvider({required String uid}) : _uid = uid {
    loadEvents();
  }

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();
    // New users start with empty calendar — no sample data.
    if (HiveService.isUserBoxEmpty(HiveService.calendarBoxName, _uid)) {
      _events = [];
    } else {
      _events = HiveService.getUserItems(
        HiveService.calendarBoxName,
        _uid,
        (map) => EventModel.fromMap(map),
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  void addEvent(
    String title,
    String location,
    DateTime startTime,
    DateTime endTime,
    String category, {
    int? reminderMinutesBefore,
  }) {
    final newEvent = EventModel(
      id: 'e_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      location: location,
      startTime: startTime,
      endTime: endTime,
      category: category,
      reminderMinutesBefore: reminderMinutesBefore,
    );
    _events.insert(0, newEvent);
    HiveService.saveUserItem(HiveService.calendarBoxName, _uid, newEvent.id, newEvent.toMap());
    _scheduleEventReminder(newEvent);
    notifyListeners();
  }

  void updateEvent(
    String id,
    String title,
    String location,
    DateTime startTime,
    DateTime endTime,
    String category, {
    int? reminderMinutesBefore,
  }) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      LocalNotificationService.cancelReminder(LocalNotificationService.notificationIdFor(id));
      _events[index] = _events[index].copyWith(
        title: title,
        location: location,
        startTime: startTime,
        endTime: endTime,
        category: category,
        reminderMinutesBefore: reminderMinutesBefore,
      );
      HiveService.saveUserItem(HiveService.calendarBoxName, _uid, _events[index].id, _events[index].toMap());
      _scheduleEventReminder(_events[index]);
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    LocalNotificationService.cancelReminder(LocalNotificationService.notificationIdFor(id));
    _events.removeWhere((e) => e.id == id);
    HiveService.deleteUserItem(HiveService.calendarBoxName, _uid, id);
    notifyListeners();
  }

  void _scheduleEventReminder(EventModel event) {
    final mins = event.reminderMinutesBefore;
    if (mins == null) return;
    final reminderTime = event.startTime.subtract(Duration(minutes: mins));
    LocalNotificationService.scheduleReminder(
      LocalNotificationService.notificationIdFor(event.id),
      '📅 Event Reminder: ${event.title}',
      'Starting ${_formatRelative(mins)} — ${event.location.isNotEmpty ? event.location : event.category}',
      reminderTime,
    );
  }

  String _formatRelative(int minutes) {
    if (minutes < 60) return 'in $minutes min';
    if (minutes < 1440) return 'in ${minutes ~/ 60}h';
    if (minutes < 10080) return 'in ${minutes ~/ 1440} day(s)';
    return 'in ${minutes ~/ 10080} week(s)';
  }
}
