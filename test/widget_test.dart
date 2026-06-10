import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fullstack_flutter_note_app/models/note.dart';
import 'package:fullstack_flutter_note_app/screens/home_screen.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'splash_seen': true});
    tempDir = Directory.systemTemp.createTempSync('notebooku_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
      Hive.registerAdapter(NoteAdapter());
    }
    await Hive.openBox<Note>('notes');
  });

  tearDown(() async {
    await Hive.box<Note>('notes').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('Notebooku renders home screen empty state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notebooku'), findsOneWidget);
    expect(find.text('Belum ada catatan'), findsOneWidget);
  });
}
