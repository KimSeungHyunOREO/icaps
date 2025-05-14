// lib/models/food_item.dart
class FoodItem {
  final String name;
  final double energy;
  final double carb;
  final double protein;
  final double sodium;

  FoodItem({
    required this.name,
    required this.energy,
    required this.carb,
    required this.protein,
    required this.sodium,
  });

  factory FoodItem.fromJson(Map<String, dynamic> j) {
    // 영문/국문 키 모두 대응
    final n =  (j['name'] ?? j['식품명'] ?? '').toString();
    double num(dynamic v) => (v ?? 0).toDouble();

    return FoodItem(
      name: n,
      energy : num(j['energy' ] ?? j['에너지(kcal)']),
      carb   : num(j['carb'   ] ?? j['탄수화물(g)']),
      protein: num(j['protein'] ?? j['단백질(g)']),
      sodium : num(j['sodium' ] ?? j['나트륨(mg)']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'energy': energy,
    'carb': carb,
    'protein': protein,
    'sodium': sodium,
  };
}
