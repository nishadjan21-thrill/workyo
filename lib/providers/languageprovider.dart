import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Called when user selects language
  Future<void> setLocale(Locale locale) async {
    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    notifyListeners();
  }

  /// Called when app starts
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code');

    if (savedCode != null) {
      _locale = Locale(savedCode);
      notifyListeners();
    }
  }
}
