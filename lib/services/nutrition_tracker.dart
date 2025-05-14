// lib/services/nutrition_tracker.dart

import '../models/child_profile.dart';
import '../models/meal_photo.dart';
import '../models/recommended_intake.dart';

class NutritionSummary {
  final double energy;
  final double carb;
  final double protein;
  final double sodium;

  NutritionSummary({
    required this.energy,
    required this.carb,
    required this.protein,
    required this.sodium,
  });
}

class NutritionTracker {
  static NutritionSummary getTodayIntake(
      String childName, List<MealPhoto> photos) {
    final today = DateTime.now();
    final todayPhotos = photos.where((p) =>
    p.childName == childName &&
        p.date.year == today.year &&
        p.date.month == today.month &&
        p.date.day == today.day);

    double totalEnergy = 0;
    double totalCarb = 0;
    double totalProtein = 0;
    double totalSodium = 0;

    for (final photo in todayPhotos) {
      totalEnergy += photo.energy;
      totalCarb += photo.carb;
      totalProtein += photo.protein;
      totalSodium += photo.sodium;
    }

    return NutritionSummary(
      energy: totalEnergy,
      carb: totalCarb,
      protein: totalProtein,
      sodium: totalSodium,
    );
  }

  static NutritionSummary getDeficit(
      RecommendedIntake rec, NutritionSummary taken) {
    return NutritionSummary(
      energy: rec.energy - taken.energy,
      carb: rec.carb - taken.carb,
      protein: rec.protein - taken.protein,
      sodium: rec.sodium - taken.sodium,
    );
  }
}
