import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _isLanguageSelected = false;

  Locale get locale => _locale;
  bool get isLanguageSelected => _isLanguageSelected;

  /// Called when user selects language
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    _isLanguageSelected = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setBool('language_selected', true);

    notifyListeners();
  }

  /// Called when app starts
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCode = prefs.getString('language_code');
    final isSelected = prefs.getBool('language_selected') ?? false;

    if (savedCode != null) {
      _locale = Locale(savedCode);
    }

    _isLanguageSelected = isSelected;

    notifyListeners();
  }
}
