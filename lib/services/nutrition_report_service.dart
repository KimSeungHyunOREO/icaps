// lib/services/nutrition_report_service.dart
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_photo.dart';
import '../models/recommended_intake.dart';

class NutrientIntake {
  final double energy;
  final double carb;
  final double protein;
  final double sodium;

  NutrientIntake(this.energy, this.carb, this.protein, this.sodium);
}

Future<NutrientIntake> getTodayIntake(String childName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'meals_$childName';
  final list = prefs.getStringList(key) ?? [];

  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  double energy = 0, carb = 0, protein = 0, sodium = 0;

  for (final e in list) {
    final data = jsonDecode(e);
    final date = data['date'];

    if (date.startsWith(today)) {
      if (date.endsWith('-food')) {
        // 음식 선택 기반
        final foods = data['foods'] as List<dynamic>;
        for (final f in foods) {
          energy += (f['energy'] ?? 0).toDouble();
          carb += (f['carb'] ?? 0).toDouble();
          protein += (f['protein'] ?? 0).toDouble();
          sodium += (f['sodium'] ?? 0).toDouble();
        }
      } else {
        // 사진 기반
        final photo = MealPhoto.fromJson(data);
        energy += photo.energy;
        carb += photo.carb;
        protein += photo.protein;
        sodium += photo.sodium;
      }
    }
  }

  return NutrientIntake(energy, carb, protein, sodium);
}

NutrientIntake getDeficit(RecommendedIntake rec, NutrientIntake actual) {
  return NutrientIntake(
    rec.energy - actual.energy,
    rec.carb - actual.carb,
    rec.protein - actual.protein,
    rec.sodium - actual.sodium,
  );
}
