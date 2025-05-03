// lib/models/food_item.dart
class FoodItem {
  final String name;
  final Map<String, String> nutrients;

  FoodItem({required this.name, required this.nutrients});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final Map<String, String> nutrientMap = {};
    for (var entry in json.entries) {
      if (entry.key != '식품명') {
        nutrientMap[entry.key] = entry.value.toString();
      }
    }

    return FoodItem(
      name: json['식품명'] ?? '',
      nutrients: nutrientMap,
    );
  }
}
