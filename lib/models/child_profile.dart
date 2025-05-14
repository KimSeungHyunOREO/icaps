// lib/models/child_profile.dart
class ChildProfile {
  String name;
  int age;
  double height;   // cm
  double weight;   // kg
  String gender;   // 'M' | 'F'
  String? avatarPath;

  ChildProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    this.avatarPath,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
    name: json['name'],
    age: json['age'],
    height: (json['height'] ?? 0).toDouble(),
    weight: (json['weight'] ?? 0).toDouble(),
    gender: json['gender'] ?? 'M',
    avatarPath: json['avatarPath'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'height': height,
    'weight': weight,
    'gender': gender,
    'avatarPath': avatarPath,
  };
}
