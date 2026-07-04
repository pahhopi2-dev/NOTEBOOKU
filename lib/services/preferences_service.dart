import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _splashSeenKey = 'splash_seen';
  static const _favoritesKey = 'favorite_notes';
  static const _archivedKey = 'archived_notes';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (error, stackTrace) {
      debugPrint('Preferences init failed: $error');
      debugPrint('$stackTrace');
      _prefs = null;
    }
  }

  static bool get splashSeen => _prefs?.getBool(_splashSeenKey) ?? false;

  static Future<void> setSplashSeen() async {
    await _prefs?.setBool(_splashSeenKey, true);
  }

  static Set<String> get favoriteIds {
    return _prefs?.getStringList(_favoritesKey)?.toSet() ?? {};
  }

  static Set<String> get archivedIds {
    return _prefs?.getStringList(_archivedKey)?.toSet() ?? {};
  }

  static Future<void> toggleFavorite(String noteId) async {
    final ids = favoriteIds;
    if (ids.contains(noteId)) {
      ids.remove(noteId);
    } else {
      ids.add(noteId);
    }
    await _prefs?.setStringList(_favoritesKey, ids.toList());
  }

  static Future<void> toggleArchive(String noteId) async {
    final ids = archivedIds;
    if (ids.contains(noteId)) {
      ids.remove(noteId);
    } else {
      ids.add(noteId);
    }
    await _prefs?.setStringList(_archivedKey, ids.toList());
  }

  static bool isFavorite(String noteId) => favoriteIds.contains(noteId);

  static bool isArchived(String noteId) => archivedIds.contains(noteId);
}
