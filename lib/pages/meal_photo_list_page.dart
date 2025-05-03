// lib/pages/meal_photo_list_page.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_photo.dart';

/// Page: View Today's Meal Photos
class MealPhotoListPage extends StatefulWidget {
  final String childName;
  const MealPhotoListPage({Key? key, required this.childName}) : super(key: key);

  @override
  State<MealPhotoListPage> createState() => _MealPhotoListPageState();
}

class _MealPhotoListPageState extends State<MealPhotoListPage> {
  List<MealPhoto> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('meal_photos') ?? [];
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4,'0')}-'
        '${now.month.toString().padLeft(2,'0')}-'
        '${now.day.toString().padLeft(2,'0')}';

    setState(() {
      _photos = stored
          .map((e) => MealPhoto.fromJson(jsonDecode(e)))
          .where((m) =>
      m.childName == widget.childName && m.date == date)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.childName} Meal Photos')),
      body: _photos.isEmpty
          ? const Center(child: Text('No photos for today.'))
          : ListView.builder(
        itemCount: _photos.length,
        itemBuilder: (ctx, i) {
          final m = _photos[i];
          return ListTile(
            leading: Image.file(
              File(m.imagePath),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(
              '${m.mealType[0].toUpperCase()}${m.mealType.substring(1)}',
            ),
          );
        },
      ),
    );
  }
}
