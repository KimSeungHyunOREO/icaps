// lib/pages/food_search_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/food_item.dart';

class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({super.key});

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  List<FoodItem> _allItems = [];
  List<FoodItem> _results = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadFoodData();
  }

  Future<void> _loadFoodData() async {
    final jsonStr = await rootBundle.loadString('assets/food_data.json');
    final List data = jsonDecode(jsonStr);
    setState(() {
      _allItems = data.map((e) => FoodItem.fromJson(e)).toList();
    });
  }

  void _onSearch(String query) {
    setState(() {
      _query = query;
      _results = _allItems
          .where((item) => item.name.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음식 영양소 검색')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: '음식 이름 입력',
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (ctx, i) {
                final item = _results[i];
                return ExpansionTile(
                  title: Text(item.name),
                  children: item.nutrients.entries
                      .map((e) => ListTile(
                    title: Text(e.key),
                    trailing: Text(e.value),
                  ))
                      .toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
