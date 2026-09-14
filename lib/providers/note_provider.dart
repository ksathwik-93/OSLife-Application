import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/hive_service.dart';

class NoteProvider extends ChangeNotifier {
  final String _uid;

  List<NoteModel> _notes = [];
  bool _isLoading = false;

  NoteProvider({required String uid}) : _uid = uid {
    loadNotes();
  }

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    // New users start with empty notes — no sample data.
    if (HiveService.isUserBoxEmpty(HiveService.notesBoxName, _uid)) {
      _notes = [];
    } else {
      _notes = HiveService.getUserItems(
        HiveService.notesBoxName,
        _uid,
        (map) => NoteModel.fromMap(map),
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  void addNote(String title, String content, String tag, {String colorHex = '#7C3AED', bool isPinned = false}) {
    final note = NoteModel(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      tag: tag,
      updatedAt: DateTime.now(),
      isPinned: isPinned,
      colorHex: colorHex,
    );
    _notes.insert(0, note);
    HiveService.saveUserItem(HiveService.notesBoxName, _uid, note.id, note.toMap());
    notifyListeners();
  }

  void updateNote(String id, String title, String content, String tag, String colorHex) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        title: title,
        content: content,
        tag: tag,
        colorHex: colorHex,
        updatedAt: DateTime.now(),
      );
      HiveService.saveUserItem(HiveService.notesBoxName, _uid, _notes[index].id, _notes[index].toMap());
      notifyListeners();
    }
  }

  void togglePin(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(isPinned: !_notes[index].isPinned);
      HiveService.saveUserItem(HiveService.notesBoxName, _uid, _notes[index].id, _notes[index].toMap());
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    HiveService.deleteUserItem(HiveService.notesBoxName, _uid, id);
    notifyListeners();
  }
}
