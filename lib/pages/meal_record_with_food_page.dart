// lib/pages/meal_record_with_food_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_item.dart';
import '../widgets/food_selector.dart';

class MealRecordWithFoodPage extends StatefulWidget {
  final String childName;
  const MealRecordWithFoodPage({super.key, required this.childName});

  @override
  State<MealRecordWithFoodPage> createState() =>
      _MealRecordWithFoodPageState();
}

class _MealRecordWithFoodPageState extends State<MealRecordWithFoodPage> {
  List<FoodItem> _selectedFoods = [];

  Future<void> _save() async {
    if (_selectedFoods.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'meals_${widget.childName}';
    final stored = prefs.getStringList(key) ?? [];

    final d = DateTime.now();
    final dateKey =
        "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}-food";

    final updated = stored.where((e) => !e.contains(dateKey)).toList();
    updated.add(jsonEncode({
      'child': widget.childName,
      'date' : dateKey,
      'foods': _selectedFoods.map((f) => f.toJson()).toList(),
    }));
    await prefs.setStringList(key, updated);

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('식사 기록 완료')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.childName} 식사 기록")),
      body: Column(
        children: [
          Expanded(
            child: FoodSelector(
              onSelect: (List<FoodItem> sel) =>
                  setState(() => _selectedFoods = sel),
            ),
          ),
          if (_selectedFoods.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("선택된 음식",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ..._selectedFoods.map(
                        (f) =>
                        Text("• ${f.name}  (${f.energy.toStringAsFixed(0)} kcal)"),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child:
              ElevatedButton(onPressed: _save, child: const Text('기록 저장')),
            ),
          ),
        ],
      ),
    );
  }
}
