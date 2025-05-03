import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';  // ✅ debugPrint 사용을 위해 추가
import '../models/food_model.dart';

class FoodService {
  static Future<List<Food>> loadFoods() async {
    final jsonString = await rootBundle.loadString('assets/data/food_data.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString); // ⬅️ Map으로 디코드

    final List<Food> foods = [];

    for (var entry in jsonMap.entries) {
      final List items = entry.value;
      for (var item in items) {
        try {
          foods.add(Food.fromJson(item));
        } catch (e) {
          debugPrint('❌ 오류 발생: $e');
        }
      }
    }

    debugPrint('✅ 총 ${foods.length}개 식품 로딩 완료');
    return foods;
  }
}
