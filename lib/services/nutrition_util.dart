// lib/services/nutrition_util.dart
import '../models/child_profile.dart';
import '../models/recommended_intake.dart';

RecommendedIntake? matchIntake(ChildProfile p, List<RecommendedIntake> table) {
  try {
    if (p.age <= 2) {
      return table.firstWhere((t) => t.group.contains('1‑2'));
    }
    if (p.age <= 5) {
      return table.firstWhere((t) => t.group.contains('3‑5'));
    }
    if (p.age <= 11) {
      return table.firstWhere((t) => t.group.contains('6‑11'));
    }
    if (p.age <= 18) {
      return table.firstWhere((t) =>
      t.group.contains('12‑18') &&
          (p.gender == 'M' ? t.group.contains('남') : t.group.contains('여')));
    }
    if (p.age <= 29) {
      return table.firstWhere((t) =>
      t.group.contains('19‑29') &&
          (p.gender == 'M' ? t.group.contains('남') : t.group.contains('여')));
    }
    if (p.age <= 49) {
      return table.firstWhere((t) =>
      t.group.contains('30‑49') &&
          (p.gender == 'M' ? t.group.contains('남') : t.group.contains('여')));
    }
    return table.firstWhere((t) =>
    t.group.contains('50') &&
        (p.gender == 'M' ? t.group.contains('남') : t.group.contains('여')));
  } catch (e) {
    print('[matchIntake] 권장 섭취량 그룹을 찾을 수 없습니다: ${e.toString()}');
    return null;
  }
}
