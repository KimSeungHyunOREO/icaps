class Food {
  final String name;
  final double energy;
  final double protein;
  final double fat; // ✅ 추가
  final double carbohydrate;
  final double sugar;
  final double calcium;
  final double sodium;
  final double vitaminC;

  Food({
    required this.name,
    required this.energy,
    required this.protein,
    required this.fat, // ✅ 추가
    required this.carbohydrate,
    required this.sugar,
    required this.calcium,
    required this.sodium,
    required this.vitaminC,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null || value == '' || value == '-') return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Food(
      name: json['name'] ?? '',
      energy: parseDouble(json['energy']),
      protein: parseDouble(json['protein']),
      fat: parseDouble(json['fat']), // ✅ 추가 (JSON에서 'fat'이라는 키여야 함)
      carbohydrate: parseDouble(json['carbohydrate']),
      sugar: parseDouble(json['sugar']),
      calcium: parseDouble(json['calcium']),
      sodium: parseDouble(json['sodium']),
      vitaminC: parseDouble(json['vitamin_c']),
    );
  }
}
