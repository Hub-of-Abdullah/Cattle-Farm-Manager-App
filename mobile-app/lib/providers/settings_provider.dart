import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', '');

  Locale get locale => _locale;

  void setLocale(String languageCode) {
    _locale = Locale(languageCode, '');
    notifyListeners();
  }

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      setLocale('bn');
    } else {
      setLocale('en');
    }
  }
}
