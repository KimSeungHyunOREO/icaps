import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/food_service.dart';

class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({super.key});

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  List<Food> _allFoods = [];
  List<Food> _filteredFoods = [];

  @override
  void initState() {
    super.initState();
    _loadFoodData();
  }

  Future<void> _loadFoodData() async {
    final foods = await FoodService.loadFoods();
    setState(() {
      _allFoods = foods;
      _filteredFoods = foods;
    });

    // 🔍 로드된 식품명 전체 출력 (디버깅용)
    debugPrint(_allFoods.map((e) => e.name).join('\n'));
  }

  void _search(String keyword) {
    final query = keyword.trim().toLowerCase(); // ✅ 공백 제거 + 소문자 변환
    setState(() {
      _filteredFoods = _allFoods.where((food) {
        return food.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('식품 성분 검색')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: '식품명을 입력하세요',
                border: OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _filteredFoods.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : ListView.builder(
              itemCount: _filteredFoods.length,
              itemBuilder: (context, index) {
                final f = _filteredFoods[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(f.name),
                    subtitle: Text(
                        '에너지: ${f.energy} kcal\n탄수화물: ${f.carbohydrate}g\n단백질: ${f.protein}g'),
                    trailing: Text('나트륨: ${f.sodium}mg'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
