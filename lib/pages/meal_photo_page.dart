// lib/pages/meal_photo_page.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_photo.dart';

/// Page: Record Meal Photo
class MealPhotoPage extends StatefulWidget {
  final String childName;
  const MealPhotoPage({Key? key, required this.childName}) : super(key: key);

  @override
  State<MealPhotoPage> createState() => _MealPhotoPageState();
}

class _MealPhotoPageState extends State<MealPhotoPage> {
  final _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
  String _selectedMeal = 'Breakfast';
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _image = File(file.path));
  }

  Future<void> _savePhoto() async {
    if (_image == null) return;

    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4,'0')}-'
        '${now.month.toString().padLeft(2,'0')}-'
        '${now.day.toString().padLeft(2,'0')}';

    final prefs = await SharedPreferences.getInstance();
    final key = 'meal_photos';
    final stored = prefs.getStringList(key) ?? [];

    final photo = MealPhoto(
      childName: widget.childName,
      date: date,
      mealType: _selectedMeal.toLowerCase(),
      imagePath: _image!.path,
    );

    // remove any existing for same child/date/mealType
    final updated = stored.where((e) {
      final m = MealPhoto.fromJson(jsonDecode(e));
      return !(m.childName == photo.childName &&
          m.date      == photo.date &&
          m.mealType  == photo.mealType);
    }).toList();

    updated.add(jsonEncode(photo.toJson()));
    await prefs.setStringList(key, updated);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Meal photo saved')));
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
            DropdownButton<String>(
              value: _selectedMeal,
              items: _mealTypes
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedMeal = v!),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: _image != null
                  ? Image.file(_image!, height: 200)
                  : Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.camera_alt, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePhoto,
              child: const Text('Save Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
