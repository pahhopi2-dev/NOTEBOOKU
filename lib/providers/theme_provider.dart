import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode { light, dark, system }

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, AppThemeMode>(
      (ref) => ThemeNotifier(),
    );

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system);

  void toggleTheme(AppThemeMode mode) {
    state = mode;
  }

  void cycleTheme() {
    switch (state) {
      case AppThemeMode.light:
        state = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        state = AppThemeMode.system;
        break;
      case AppThemeMode.system:
        state = AppThemeMode.light;
        break;
    }
  }
}
