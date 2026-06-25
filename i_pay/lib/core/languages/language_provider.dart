import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_lang') ?? 'en';

    debugPrint('🌍 LanguageProvider.init() → loaded lang = $code');

    _locale = Locale(code);

    debugPrint('✅ Locale updated to ${_locale.languageCode}');

    notifyListeners();
  }

  Future<void> changeLanguage(String code) async {
    if (_locale.languageCode == code) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', code);

    _locale = Locale(code);
    notifyListeners(); // 🔥 rebuilds whole app
  }
}
