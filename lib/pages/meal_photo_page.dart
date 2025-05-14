import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_photo.dart';
import '../models/food_item.dart';
import '../widgets/food_selector.dart';

class MealPhotoPage extends StatefulWidget {
  final String childName;
  const MealPhotoPage({super.key, required this.childName});

  @override
  State<MealPhotoPage> createState() => _MealPhotoPageState();
}

class _MealPhotoPageState extends State<MealPhotoPage> {
  final _picker = ImagePicker();
  final _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  String  _meal = 'Breakfast';
  File?   _image;
  List<FoodItem> _foods = [];

  Future<void> _pickImage() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _image = File(f.path));
  }

  Future<void> _save() async {
    if (_image == null) return;

    // 영양소 합산
    double e = 0, c = 0, p = 0, s = 0;
    for (final f in _foods) {
      e += f.energy; c += f.carb; p += f.protein; s += f.sodium;
    }

    final today = DateTime.now();
    final photo = MealPhoto(
      childName: widget.childName,
      date: DateTime(today.year, today.month, today.day),
      mealType: _meal.toLowerCase(),
      imagePath: _image!.path,
      energy: e,
      carb: c,
      protein: p,
      sodium: s,
    );

    final prefs  = await SharedPreferences.getInstance();
    final key    = 'meals_${widget.childName}';
    final saved  = prefs.getStringList(key) ?? [];

    // 동일 식사(아침/점심/저녁) 중복 제거
    final updated = saved.where((e) {
      final m = MealPhoto.fromJson(jsonDecode(e));
      return !(m.mealType == photo.mealType &&
          m.date     == photo.date &&
          m.childName== photo.childName);
    }).toList();

    updated.add(jsonEncode(photo.toJson()));
    await prefs.setStringList(key, updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('저장 완료')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Meal Photo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 식사 종류
            DropdownButton<String>(
              value: _meal,
              items: _mealTypes
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _meal = v!),
            ),
            const SizedBox(height: 12),
            // 이미지 선택
            GestureDetector(
              onTap: _pickImage,
              child: _image != null
                  ? Image.file(_image!, height: 180)
                  : Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.camera_alt, size: 50)),
              ),
            ),
            const SizedBox(height: 12),
            // 음식 검색
            Expanded(
              child: FoodSelector(
                onSelect: (foods) => setState(() => _foods = foods),
              ),
            ),
            if (_foods.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('선택된 음식 (${_foods.length})'),
              ..._foods.map(
                      (f) => Text('• ${f.name}  (${f.energy.toStringAsFixed(0)} kcal)')),
            ],
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _save, child: const Text('Save Photo')),
          ],
        ),
      ),
    );
  }
}
