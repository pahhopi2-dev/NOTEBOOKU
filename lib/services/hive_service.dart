import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/note.dart';

class HiveService {
  static const String _notesBox = 'notes';

  static Future<void> bootstrap() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
        Hive.registerAdapter(NoteAdapter());
      }
      if (!Hive.isBoxOpen(_notesBox)) {
        await Hive.openBox<Note>(_notesBox);
      }
    } catch (error, stackTrace) {
      debugPrint('Hive bootstrap failed: $error');
      debugPrint('$stackTrace');
      await _recoverFromCorruptBox();
    }
  }

  static Future<void> _recoverFromCorruptBox() async {
    try {
      if (Hive.isBoxOpen(_notesBox)) {
        await Hive.box<Note>(_notesBox).close();
      }
      await Hive.deleteBoxFromDisk(_notesBox);
    } catch (error) {
      debugPrint('Hive cleanup failed: $error');
    }

    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
        Hive.registerAdapter(NoteAdapter());
      }
      if (!Hive.isBoxOpen(_notesBox)) {
        await Hive.openBox<Note>(_notesBox);
      }
    } catch (error, stackTrace) {
      debugPrint('Hive recovery failed: $error');
      debugPrint('$stackTrace');
    }
  }

  static Box<Note> get notesBox => Hive.box<Note>(_notesBox);

  static Future<void> saveNote(Note note) async {
    await notesBox.put(note.id, note);
  }

  static Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  static Future<void> updateNote(Note note) async {
    await saveNote(note);
  }

  static List<Note> getAllNotes() {
    return notesBox.values.toList();
  }

  static Note? getNote(String id) {
    return notesBox.get(id);
  }

  static Future<void> clearAll() async {
    await notesBox.clear();
  }

  static int get notesCount => notesBox.length;

  static Stream<BoxEvent> watchNotes() {
    return notesBox.watch();
  }
}
