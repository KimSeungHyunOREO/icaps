import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/food_search_page.dart';
import 'screens/children_list_page.dart';
import 'screens/profile_settings_page.dart';
import 'pages/meal_photo_list_page.dart';
import 'pages/meal_photo_page.dart';
import 'meal_history_page.dart';
import 'models/child_profile.dart';
import 'service/language_service.dart';
import 'screens/home_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyAppWrapper(),
    ),
  );
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageService(),
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context);
    return MaterialApp(
      title: 'Star Plate',
      theme: ThemeData(primarySwatch: Colors.green),
      locale: lang.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: const HomePage(),
    );
  }
}


class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context);
    return AlertDialog(
      title: Text('language'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<Locale>(
            value: const Locale('en'),
            groupValue: lang.locale,
            title: const Text('English'),
            onChanged: (val) {
              if (val != null) lang.setLocale(context, val);
            },
          ),
          RadioListTile<Locale>(
            value: const Locale('ko'),
            groupValue: lang.locale,
            title: const Text('한국어'),
            onChanged: (val) {
              if (val != null) lang.setLocale(context, val);
            },
          ),
        ],
      ),
    );
  }
}
