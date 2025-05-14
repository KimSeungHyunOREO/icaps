class RecommendedIntake {
  final String group;
  final double energy;   // kcal
  final double carb;     // g
  final double protein;  // g
  final double sodium;   // mg

  RecommendedIntake({
    required this.group,
    required this.energy,
    required this.carb,
    required this.protein,
    required this.sodium,
  });

  factory RecommendedIntake.fromJson(Map<String, dynamic> json) {
    return RecommendedIntake(
      group: json['group'],
      energy: (json['energy'] ?? 0).toDouble(),
      carb: (json['carb'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      sodium: (json['sodium'] ?? 0).toDouble(),
    );
  }
}
