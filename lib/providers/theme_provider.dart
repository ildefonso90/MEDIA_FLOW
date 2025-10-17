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
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    ),
  );
}
