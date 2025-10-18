import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  late Box<AppSettings> _settingsBox;
  late AppSettings _settings;

  ThemeProvider() {
    _settingsBox = Hive.box<AppSettings>(AppConstants.hiveBoxSettings);
    _loadSettings();
  }

  void _loadSettings() {
    _settings = _settingsBox.get(AppConstants.settingsKey) ?? AppSettings();
    if (!_settingsBox.containsKey(AppConstants.settingsKey)) {
      _settingsBox.put(AppConstants.settingsKey, _settings);
    }
  }

  bool get isDarkMode => _settings.isDarkMode;

  ThemeMode get themeMode => _settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _settings.isDarkMode = !_settings.isDarkMode;
    _settings.save();
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE53935),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 3,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
      activeTrackColor: Color(0xFFE53935),
      thumbColor: Color(0xFFE53935),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE53935),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF121212),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 3,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
      activeTrackColor: Color(0xFFE53935),
      thumbColor: Color(0xFFE53935),
    ),
  );
}
