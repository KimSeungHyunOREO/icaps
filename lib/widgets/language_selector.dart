import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../service/language_service.dart';

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
