import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:alarm_from_hell/core/constants/storage_constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Hive에서 테마 설정 로드
  Future<void> loadThemeFromHive() async {
    final box = await Hive.openBox(StorageConstants.themeBoxName);
    final isDark =
        box.get(StorageConstants.isDarkModeKey, defaultValue: true) as bool;
    setDarkMode(isDark);
  }

  // Hive에 테마 설정 저장
  Future<void> saveThemeToHive(bool isDark) async {
    final box = await Hive.openBox(StorageConstants.themeBoxName);
    await box.put(StorageConstants.isDarkModeKey, isDark);
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    saveThemeToHive(!isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// 전역 인스턴스 생성
final themeProvider = ThemeProvider();
