import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child_profile.dart';
import '../models/meal_photo.dart';
import '../screens/profile_settings_page.dart';
import '../pages/meal_photo_page.dart';
import '../pages/meal_photo_list_page.dart';
import '../meal_history_page.dart';


// ⛳ Children List / Profile Management
class ChildrenListPage extends StatefulWidget {
  const ChildrenListPage({super.key});

  @override
  State<ChildrenListPage> createState() => _ChildrenListPageState();
}

class _ChildrenListPageState extends State<ChildrenListPage> {
  final List<ChildProfile> _children = [];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('children') ?? [];
    setState(() {
      _children
        ..clear()
        ..addAll(stored.map((e) => ChildProfile.fromJson(jsonDecode(e))));
    });
  }

  Future<void> _saveChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _children.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList('children', encoded);
  }

  void _addChild() async {
    final profile = await Navigator.push<ChildProfile>(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSettingsPage()),
    );
    if (profile != null) {
      setState(() => _children.add(profile));
      await _saveChildren();
    }
  }

  void _editChild(int i) async {
    final updated = await Navigator.push<ChildProfile>(
      context,
      MaterialPageRoute(
          builder: (_) => ProfileSettingsPage(profile: _children[i])),
    );
    if (updated != null) {
      setState(() => _children[i] = updated);
      await _saveChildren();
    }
  }

  void _deleteChild(int i) async {
    setState(() => _children.removeAt(i));
    await _saveChildren();
  }

  void _recordMealPhoto(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealPhotoPage(childName: _children[i].name),
      ),
    );
  }

  void _viewMealPhotos(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealPhotoListPage(childName: _children[i].name),
      ),
    );
  }

  void _viewMealHistory(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealHistoryPage(childName: _children[i].name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Children')),
      body: ListView.builder(
        itemCount: _children.length,
        itemBuilder: (ctx, i) {
          final c = _children[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: c.avatarPath != null
                  ? CircleAvatar(backgroundImage: FileImage(File(c.avatarPath!)))
                  : const CircleAvatar(child: Icon(Icons.child_friendly)),
              title: Text(c.name),
              subtitle: Text('${c.age} years'),
              onLongPress: () => _showDeleteDialog(i, c.name),
              trailing: _buildPopupMenu(i),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChild,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ───────────────────────── helper ─────────────────────────
  PopupMenuButton<String> _buildPopupMenu(int idx) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'view':
            _viewMealPhotos(idx);
            break;
          case 'record':
            _recordMealPhoto(idx);
            break;
          case 'edit':
            _editChild(idx);
            break;
          case 'history':
            _viewMealHistory(idx);
            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'view', child: Text('View Meal Photos')),
        PopupMenuItem(value: 'record', child: Text('Record Meal')),
        PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
        PopupMenuItem(value: 'history', child: Text('Meal History')),
      ],
    );
  }

  void _showDeleteDialog(int idx, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Delete profile for $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChild(idx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
