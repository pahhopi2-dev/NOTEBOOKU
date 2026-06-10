import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../services/hive_service.dart';
import '../services/preferences_service.dart';

enum NotesSort { updated, created, title }

class NotesState {
  final List<Note> notes;
  final String selectedCategory;
  final String searchQuery;
  final NotesSort sort;
  final bool isLoading;
  final Set<String> favoriteIds;
  final Set<String> archivedIds;

  const NotesState({
    this.notes = const [],
    this.selectedCategory = 'all',
    this.searchQuery = '',
    this.sort = NotesSort.updated,
    this.isLoading = false,
    this.favoriteIds = const {},
    this.archivedIds = const {},
  });

  List<Note> _sorted(List<Note> input) {
    final result = [...input];
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      switch (sort) {
        case NotesSort.created:
          return b.createdAt.compareTo(a.createdAt);
        case NotesSort.title:
          return a.displayTitle.toLowerCase().compareTo(
            b.displayTitle.toLowerCase(),
          );
        case NotesSort.updated:
          return b.updatedAt.compareTo(a.updatedAt);
      }
    });
    return result;
  }

  List<Note> get activeNotes {
    return notes.where((n) => !archivedIds.contains(n.id)).toList();
  }

  List<Note> get filteredNotes {
    final query = searchQuery.trim();
    final result = activeNotes.where((note) {
      final matchesCategory =
          selectedCategory == 'all' || note.category == selectedCategory;
      return matchesCategory && note.matches(query);
    }).toList();
    return _sorted(result);
  }

  List<Note> get pinnedNotes {
    return filteredNotes.where((note) => note.isPinned).toList();
  }

  List<Note> get taskNotes {
    return filteredNotes.where((note) => note.isTaskLike).toList();
  }

  List<Note> get favoriteNotes {
    return _sorted(
      activeNotes
          .where((n) => favoriteIds.contains(n.id))
          .where((n) => n.matches(searchQuery))
          .toList(),
    );
  }

  List<Note> get archivedNotes {
    return _sorted(
      notes
          .where((n) => archivedIds.contains(n.id))
          .where((n) => n.matches(searchQuery))
          .toList(),
    );
  }

  List<Note> get recentNotes {
    return _sorted([...activeNotes]).take(5).toList();
  }

  int get totalWords {
    return activeNotes.fold<int>(0, (total, note) => total + note.wordCount);
  }

  int get completedTasks {
    return activeNotes.fold<int>(
      0,
      (total, note) => total + note.checklistDone,
    );
  }

  int get totalTasks {
    return activeNotes.fold<int>(
      0,
      (total, note) => total + note.checklistTotal,
    );
  }

  bool isFavorite(String id) => favoriteIds.contains(id);

  bool isArchived(String id) => archivedIds.contains(id);

  NotesState copyWith({
    List<Note>? notes,
    String? selectedCategory,
    String? searchQuery,
    NotesSort? sort,
    bool? isLoading,
    Set<String>? favoriteIds,
    Set<String>? archivedIds,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sort: sort ?? this.sort,
      isLoading: isLoading ?? this.isLoading,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      archivedIds: archivedIds ?? this.archivedIds,
    );
  }
}

final notesNotifierProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<NotesState>>(
      (ref) => NotesNotifier(),
    );

class NotesNotifier extends StateNotifier<AsyncValue<NotesState>> {
  NotesNotifier() : super(const AsyncLoading()) {
    refresh();
  }

  NotesState get _current => state.valueOrNull ?? const NotesState();

  Future<void> refresh() async {
    try {
      final notes = HiveService.getAllNotes();
      state = AsyncData(
        _current.copyWith(
          notes: notes,
          isLoading: false,
          favoriteIds: PreferencesService.favoriteIds,
          archivedIds: PreferencesService.archivedIds,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> saveNote(Note note) async {
    final current = _current;
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      await HiveService.saveNote(note);
      final existingIndex = current.notes.indexWhere(
        (savedNote) => savedNote.id == note.id,
      );
      final nextNotes = [...current.notes];

      if (existingIndex >= 0) {
        nextNotes[existingIndex] = note;
      } else {
        nextNotes.add(note);
      }

      state = AsyncData(current.copyWith(notes: nextNotes, isLoading: false));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteNote(String id) async {
    final current = _current;
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      await HiveService.deleteNote(id);
      final nextNotes = current.notes.where((note) => note.id != id).toList();
      state = AsyncData(current.copyWith(notes: nextNotes, isLoading: false));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> togglePin(Note note) async {
    await saveNote(
      note.copyWith(isPinned: !note.isPinned, updatedAt: DateTime.now()),
    );
  }

  Future<void> toggleFavorite(Note note) async {
    await PreferencesService.toggleFavorite(note.id);
    state = AsyncData(
      _current.copyWith(favoriteIds: PreferencesService.favoriteIds),
    );
  }

  Future<void> toggleArchive(Note note) async {
    await PreferencesService.toggleArchive(note.id);
    state = AsyncData(
      _current.copyWith(archivedIds: PreferencesService.archivedIds),
    );
  }

  Future<void> duplicateNote(Note note) async {
    final now = DateTime.now();
    await saveNote(
      note.copyWith(
        id: const Uuid().v4(),
        title: '${note.displayTitle} copy',
        createdAt: now,
        updatedAt: now,
        isPinned: false,
      ),
    );
  }

  Future<void> clearAll() async {
    final current = _current;
    state = AsyncData(current.copyWith(isLoading: true));

    try {
      await HiveService.clearAll();
      state = AsyncData(current.copyWith(notes: const [], isLoading: false));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> seedDemoNotes() async {
    if (_current.notes.isNotEmpty) return;

    final now = DateTime.now();
    final samples = [
      Note(
        id: const Uuid().v4(),
        title: 'Rencana minggu ini',
        content:
            '- [ ] Rapikan materi kuliah\n- [x] Review catatan project\n'
            '- [ ] Kirim update ke tim',
        category: 'tasks',
        color: 'mint',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        isPinned: true,
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Ide fitur Notebooku',
        content:
            'Tambahkan quick capture, mode fokus, dan sync manual '
            'yang tetap aman saat offline.',
        category: 'ideas',
        color: 'sun',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Note(
        id: const Uuid().v4(),
        title: 'Meeting produk',
        content:
            'Bahas prioritas rilis, bug utama, dan target eksperimen '
            'untuk user baru.',
        category: 'work',
        color: 'sky',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(minutes: 45)),
      ),
    ];

    for (final note in samples) {
      await HiveService.saveNote(note);
    }

    state = AsyncData(_current.copyWith(notes: samples, isLoading: false));
  }

  void setCategory(String category) {
    state = AsyncData(_current.copyWith(selectedCategory: category));
  }

  void setSearch(String query) {
    state = AsyncData(_current.copyWith(searchQuery: query));
  }

  void setSort(NotesSort sort) {
    state = AsyncData(_current.copyWith(sort: sort));
  }
}
