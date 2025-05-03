import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'main.dart'; // ChildProfile·MealPhoto 모델 재사용

class MealHistoryPage extends StatefulWidget {
  final String childName;
  const MealHistoryPage({Key? key, required this.childName}) : super(key: key);

  @override
  State<MealHistoryPage> createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends State<MealHistoryPage> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  List<MealPhoto> _photos = [];
  final _noteCtrl = TextEditingController();

  String get _dateKey =>
      "${_selected.year.toString().padLeft(4, '0')}-"
          "${_selected.month.toString().padLeft(2, '0')}-"
          "${_selected.day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    // 사진 불러오기
    final stored = prefs.getStringList('meal_photos') ?? [];
    final photos = stored
        .map((e) => MealPhoto.fromJson(jsonDecode(e)))
        .where((m) => m.childName == widget.childName && m.date == _dateKey)
        .toList();
    // 메모 불러오기
    final notes = jsonDecode(prefs.getString('meal_notes') ?? '{}')
    as Map<String, dynamic>;
    _noteCtrl.text = notes[_dateKey] ?? '';
    setState(() => _photos = photos);
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    final notes = jsonDecode(prefs.getString('meal_notes') ?? '{}')
    as Map<String, dynamic>;
    notes[_dateKey] = _noteCtrl.text.trim();
    await prefs.setString('meal_notes', jsonEncode(notes));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.childName}'s Meal Diary")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focused,
            selectedDayPredicate: (d) =>
            d.year == _selected.year &&
                d.month == _selected.month &&
                d.day == _selected.day,
            onDaySelected: (sel, foc) {
              setState(() {
                _selected = sel;
                _focused = foc;
              });
              _load();
            },
          ),
          const Divider(),
          Expanded(
            child: _photos.isEmpty
                ? const Center(child: Text('No photos for this date'))
                : ListView.builder(
              itemCount: _photos.length,
              itemBuilder: (_, i) {
                final m = _photos[i];
                return ListTile(
                  leading: Image.file(File(m.imagePath),
                      width: 60, height: 60, fit: BoxFit.cover),
                  title: Text(
                      '${m.mealType[0].toUpperCase()}${m.mealType.substring(1)}'),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Note'),
                TextField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write anything...'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _saveNote, child: const Text('Save'))
              ],
            ),
          )
        ],
      ),
    );
  }
}
