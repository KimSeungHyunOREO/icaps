import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/recommended_intake.dart';

class RecommendedService {
  static Future<List<RecommendedIntake>> load() async {
    final raw = await rootBundle.loadString('assets/data/recommended_intake.json');
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => RecommendedIntake.fromJson(e)).toList();
  }
}
