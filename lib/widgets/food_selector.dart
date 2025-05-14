// lib/widgets/food_selector.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/food_item.dart'; // FoodItem 모델 사용

class FoodSelector extends StatefulWidget {
  final Function(List<FoodItem>) onSelect; // 선택 결과 콜백
  const FoodSelector({super.key, required this.onSelect});

  @override
  State<FoodSelector> createState() => _FoodSelectorState();
}

class _FoodSelectorState extends State<FoodSelector> {
  List<FoodItem> _allFoods    = [];
  List<FoodItem> _selected    = [];
  String         _query       = '';

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final raw  = await rootBundle.loadString('assets/data/food_data.json');
    final list = jsonDecode(raw) as List;
    setState(() {
      _allFoods = list.map((e) => FoodItem.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final qLower   = _query.toLowerCase().trim();
    final filtered = _allFoods
        .where((f) => f.name.toLowerCase().contains(qLower))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('음식 검색'),
        TextField(
          decoration: const InputDecoration(hintText: '예: 사과'),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final food     = filtered[i];
              final isChosen = _selected.contains(food);

              return ListTile(
                title: Text(food.name),
                subtitle: Text(
                  '에너지 ${food.energy} kcal, '
                      '탄 ${food.carb} g, '
                      '단 ${food.protein} g, '
                      '나 ${food.sodium} mg',
                ),
                trailing: isChosen
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    isChosen ? _selected.remove(food)
                        : _selected.add(food);
                    // 현재 선택 리스트를 콜백
                    widget.onSelect(List.of(_selected));
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
