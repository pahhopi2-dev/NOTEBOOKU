import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/hive_service.dart';
import 'services/preferences_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.bootstrap();
  await PreferencesService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeNotifierProvider);
    final showSplash = !PreferencesService.splashSeen;

    return MaterialApp(
      title: 'Notebooku',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeModeFromAppTheme(appThemeMode),
      home: showSplash ? const SplashScreen() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

ThemeMode _themeModeFromAppTheme(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
}
