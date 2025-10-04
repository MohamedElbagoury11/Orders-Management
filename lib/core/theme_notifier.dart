import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  static const String _themeKey = 'selected_theme';
  
  ThemeNotifier() : super(ThemeMode.system) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null) {
        value = ThemeMode.values[themeIndex];
      }
    } catch (e) {
      // If there's an error loading theme, keep the default
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  void toggleTheme() {
    final newTheme = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setTheme(newTheme);
  }

  void setTheme(ThemeMode mode) {
    value = mode;
    _saveTheme(mode);
  }
}

class LanguageNotifier extends ValueNotifier<Locale> {
  static const String _languageKey = 'selected_language';
  static const String _countryKey = 'selected_country';
  
  LanguageNotifier() : super(const Locale('en', 'US')) {
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      final countryCode = prefs.getString(_countryKey);
      
      if (languageCode != null && countryCode != null) {
        value = Locale(languageCode, countryCode);
      }
    } catch (e) {
      // If there's an error loading language, keep the default
      debugPrint('Error loading language: $e');
    }
  }

  Future<void> _saveLanguage(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      await prefs.setString(_countryKey, locale.countryCode ?? '');
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  void setLanguage(Locale locale) {
    value = locale;
    _saveLanguage(locale);
  }

  void toggleLanguage() {
    final newLocale = value.languageCode == 'en' 
        ? const Locale('ar', 'SA') 
        : const Locale('en', 'US');
    setLanguage(newLocale);
  }

  bool get isArabic => value.languageCode == 'ar';
  bool get isEnglish => value.languageCode == 'en';
} 