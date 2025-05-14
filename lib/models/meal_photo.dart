// lib/models/meal_photo.dart
import 'dart:convert';

class MealPhoto {
  final String childName;
  final DateTime date;
  final String mealType;
  final String imagePath;
  final double energy;
  final double carb;
  final double protein;
  final double sodium;

  MealPhoto({
    required this.childName,
    required this.date,
    required this.mealType,
    required this.imagePath,
    this.energy = 0,
    this.carb = 0,
    this.protein = 0,
    this.sodium = 0,
  });

  factory MealPhoto.fromJson(Map<String, dynamic> json) {
    return MealPhoto(
      childName: json['childName'],
      date: DateTime.parse(json['date']),
      mealType: json['mealType'],
      imagePath: json['imagePath'],
      energy: (json['energy'] ?? 0).toDouble(),
      carb: (json['carb'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      sodium: (json['sodium'] ?? 0).toDouble(),
    );
  }

  factory MealPhoto.fromJsonString(String str) =>
      MealPhoto.fromJson(jsonDecode(str));

  Map<String, dynamic> toJson() => {
    'childName': childName,
    'date': date.toIso8601String(),
    'mealType': mealType,
    'imagePath': imagePath,
    'energy': energy,
    'carb': carb,
    'protein': protein,
    'sodium': sodium,
  };
}
