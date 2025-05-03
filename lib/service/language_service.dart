// lib/services/language_service.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageService extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(BuildContext context, Locale newLocale) {
    _locale = newLocale;
    context.setLocale(newLocale);
    notifyListeners();
  }
}
