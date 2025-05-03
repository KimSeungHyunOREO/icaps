// lib/models/meal_photo.dart

class MealPhoto {
  final String childName;
  final String date;       // YYYY-MM-DD
  final String mealType;
  final String imagePath;

  MealPhoto({
    required this.childName,
    required this.date,
    required this.mealType,
    required this.imagePath,
  });

  factory MealPhoto.fromJson(Map<String, dynamic> json) => MealPhoto(
    childName: json['childName'],
    date: json['date'],
    mealType: json['mealType'],
    imagePath: json['imagePath'],
  );

  Map<String, dynamic> toJson() => {
    'childName': childName,
    'date': date,
    'mealType': mealType,
    'imagePath': imagePath,
  };
}
