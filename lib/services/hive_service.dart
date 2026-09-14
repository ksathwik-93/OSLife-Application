import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String tasksBoxName = 'tasks_box';
  static const String notesBoxName = 'notes_box';
  static const String calendarBoxName = 'calendar_box';
  static const String expensesBoxName = 'expenses_box';
  static const String goalsBoxName = 'goals_box';
  static const String studySubjectsBoxName = 'study_subjects_box';
  static const String studyTimetableBoxName = 'study_timetable_box';
  static const String studyAssignmentsBoxName = 'study_assignments_box';
  static const String studyExamsBoxName = 'study_exams_box';
  static const String studySessionsBoxName = 'study_sessions_box';
  static const String usersBoxName = 'users_box';
  static const String authBoxName = 'auth_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(tasksBoxName),
      Hive.openBox(notesBoxName),
      Hive.openBox(calendarBoxName),
      Hive.openBox(expensesBoxName),
      Hive.openBox(goalsBoxName),
      Hive.openBox(studySubjectsBoxName),
      Hive.openBox(studyTimetableBoxName),
      Hive.openBox(studyAssignmentsBoxName),
      Hive.openBox(studyExamsBoxName),
      Hive.openBox(studySessionsBoxName),
      Hive.openBox(usersBoxName),
      Hive.openBox(authBoxName),
    ]);
  }

  static Box _getBox(String boxName) {
    return Hive.box(boxName);
  }

  // ─── Legacy (non-scoped) helpers ────────────────────────────────────────────
  // Used by auth_service for users_box and auth_box, which are not user-scoped.

  static bool isBoxEmpty(String boxName) {
    if (!Hive.isBoxOpen(boxName)) return true;
    return _getBox(boxName).isEmpty;
  }

  static List<T> getItems<T>(String boxName, T Function(Map<dynamic, dynamic>) fromMap) {
    if (!Hive.isBoxOpen(boxName)) return [];
    final box = _getBox(boxName);
    final items = <T>[];
    for (final val in box.values) {
      if (val is Map) {
        try {
          items.add(fromMap(val));
        } catch (e) {
          // Ignore invalid or corrupt entries
        }
      }
    }
    return items;
  }

  static Future<void> saveItem(String boxName, String id, Map<String, dynamic> map) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    await box.put(id, map);
  }

  static Future<void> saveAllItems<T>(
    String boxName,
    List<T> items,
    String Function(T) getId,
    Map<String, dynamic> Function(T) toMap,
  ) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    final entries = <String, Map<String, dynamic>>{};
    for (final item in items) {
      entries[getId(item)] = toMap(item);
    }
    await box.putAll(entries);
  }

  static Future<void> deleteItem(String boxName, String id) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    await box.delete(id);
  }

  static Future<void> clearBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    await box.clear();
  }

  static Future<void> setValue(String boxName, String key, dynamic value) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    await box.put(key, value);
  }

  static dynamic getValue(String boxName, String key, {dynamic defaultValue}) {
    if (!Hive.isBoxOpen(boxName)) return defaultValue;
    final box = _getBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  static Future<void> deleteValue(String boxName, String key) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    await box.delete(key);
  }

  // ─── User-scoped helpers ─────────────────────────────────────────────────────
  // Data keys are prefixed with "{uid}::" to isolate each user's data in the
  // same shared Hive box. No data from other users is ever read or written.

  /// Returns the scoped key for a given user and item id.
  static String scopedKey(String uid, String itemId) => '$uid::$itemId';

  /// Returns true if there are no entries for [uid] in [boxName].
  static bool isUserBoxEmpty(String boxName, String uid) {
    if (!Hive.isBoxOpen(boxName)) return true;
    final box = _getBox(boxName);
    return !box.keys.any((k) => k is String && k.startsWith('$uid::'));
  }

  /// Loads all items belonging to [uid] from [boxName].
  static List<T> getUserItems<T>(
    String boxName,
    String uid,
    T Function(Map<dynamic, dynamic>) fromMap,
  ) {
    if (!Hive.isBoxOpen(boxName)) return [];
    final box = _getBox(boxName);
    final prefix = '$uid::';
    final items = <T>[];
    for (final key in box.keys) {
      if (key is String && key.startsWith(prefix)) {
        final val = box.get(key);
        if (val is Map) {
          try {
            items.add(fromMap(val));
          } catch (e) {
            // Ignore corrupt entries
          }
        }
      }
    }
    return items;
  }

  /// Saves a single item scoped to [uid].
  static Future<void> saveUserItem(
    String boxName,
    String uid,
    String itemId,
    Map<String, dynamic> map,
  ) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    await box.put(scopedKey(uid, itemId), map);
  }

  /// Saves a list of items all scoped to [uid].
  static Future<void> saveAllUserItems<T>(
    String boxName,
    String uid,
    List<T> items,
    String Function(T) getId,
    Map<String, dynamic> Function(T) toMap,
  ) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    final entries = <String, Map<String, dynamic>>{};
    for (final item in items) {
      entries[scopedKey(uid, getId(item))] = toMap(item);
    }
    await box.putAll(entries);
  }

  /// Deletes a single item scoped to [uid].
  static Future<void> deleteUserItem(
    String boxName,
    String uid,
    String itemId,
  ) async {
    if (!Hive.isBoxOpen(boxName)) return;
    final box = _getBox(boxName);
    await box.delete(scopedKey(uid, itemId));
  }
}
