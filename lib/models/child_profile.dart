// lib/models/child_profile.dart
class ChildProfile {
  String name;
  int age;
  String? avatarPath;

  ChildProfile({
    required this.name,
    required this.age,
    this.avatarPath,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
    name: json['name'],
    age: json['age'],
    avatarPath: json['avatarPath'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'avatarPath': avatarPath,
  };
}
