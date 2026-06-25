import 'package:flutter/material.dart';

class AppLanguages {
  // ✅ MUST be List<Locale>
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('bn'),
    Locale('te'),
    Locale('mr'),
    Locale('ta'),
    Locale('ur'),
    Locale('gu'),
    Locale('kn'),
    Locale('ml'),
    Locale('or'),
    Locale('pa'),
    Locale('as'),
    Locale('mai'),
    Locale('sa'),
    Locale('ks'),
    Locale('ne'),
    Locale('sd'),
    Locale('kok'),
    Locale('doi'),
    Locale('mni'),
    Locale('sat'),
  ];

  static const Locale fallback = Locale('en');

  /// Helper for validation
  static bool isSupported(String code) {
    return supportedLocales.any((l) => l.languageCode == code);
  }
}
