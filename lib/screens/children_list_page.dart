// lib/screens/children_list_page.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── models
import '../models/child_profile.dart';

// ── pages / screens
import '../screens/profile_settings_page.dart';
import '../pages/meal_record_with_food_page.dart';   // 음식만 기록
import '../pages/meal_photo_page.dart';             // 사진 + 음식 기록
import '../pages/meal_photo_list_page.dart';
import '../meal_history_page.dart';

// ── services
import '../services/recommended_service.dart';
import '../services/nutrition_util.dart';
import '../services/nutrition_report_service.dart';

class ChildrenListPage extends StatefulWidget {
  const ChildrenListPage({super.key});
  @override
  State<ChildrenListPage> createState() => _ChildrenListPageState();
}

class _ChildrenListPageState extends State<ChildrenListPage> {
  final List<ChildProfile> _children = [];

  /* ───────── load / save children ───────── */
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
    await prefs.setStringList(
        'children', _children.map((c) => jsonEncode(c.toJson())).toList());
  }

  /* ───────── profile CRUD ───────── */
  void _addChild() async {
    final p = await Navigator.push<ChildProfile>(
        context, MaterialPageRoute(builder: (_) => const ProfileSettingsPage()));
    if (p != null) {
      setState(() => _children.add(p));
      _saveChildren();
    }
  }

  void _editChild(int i) async {
    final up = await Navigator.push<ChildProfile>(
      context,
      MaterialPageRoute(builder: (_) => ProfileSettingsPage(profile: _children[i])),
    );
    if (up != null) {
      setState(() => _children[i] = up);
      _saveChildren();
    }
  }

  void _deleteChild(int i) async {
    setState(() => _children.removeAt(i));
    _saveChildren();
  }

  /* ───────── meal pages ───────── */
  void _recordMeal(int i) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MealRecordWithFoodPage(childName: _children[i].name)));
  }

  void _recordMealPhoto(int i) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MealPhotoPage(childName: _children[i].name)));
  }

  void _viewMealPhotos(int i) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MealPhotoListPage(childName: _children[i].name)));
  }

  void _viewMealHistory(int i) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MealHistoryPage(childName: _children[i].name)));
  }

  /* ───────── optional pop-ups (권장치/리포트) ───────── */
  Future<void> _showRecommendedIntake(int i) async {
    final profile = _children[i];
    final rec = matchIntake(profile, await RecommendedService.load());
    if (rec == null) return;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: Text('${profile.name} 권장 섭취량'),
            content: Text(
                'Energy : ${rec.energy} kcal\n'
                    'Carb   : ${rec.carb} g\n'
                    'Protein: ${rec.protein} g\n'
                    'Sodium : ${rec.sodium} mg'),
            actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('OK'))]));
  }

  Future<void> _showNutritionReport(int i) async {
    final p   = _children[i];
    final rec = matchIntake(p, await RecommendedService.load());
    if (rec == null) return;
    final taken   = await getTodayIntake(p.name);
    final deficit = getDeficit(rec, taken);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: Text('${p.name} 영양 리포트'),
            content: Text(
                '오늘 섭취 / 권장\n'
                    'Energy : ${taken.energy.toStringAsFixed(1)} / ${rec.energy} kcal\n'
                    'Carb   : ${taken.carb.toStringAsFixed(1)} / ${rec.carb} g\n'
                    'Protein: ${taken.protein.toStringAsFixed(1)} / ${rec.protein} g\n'
                    'Sodium : ${taken.sodium.toStringAsFixed(1)} / ${rec.sodium} mg\n\n'
                    '부족분\n'
                    '${deficit.energy>0?'Energy ${deficit.energy.toStringAsFixed(1)} kcal\n':''}'
                    '${deficit.carb  >0?'Carb   ${deficit.carb.toStringAsFixed(1)} g\n':''}'
                    '${deficit.protein>0?'Protein${deficit.protein.toStringAsFixed(1)} g\n':''}'
                    '${deficit.sodium >0?'Sodium ${deficit.sodium.toStringAsFixed(1)} mg\n':''}'.trim()),
            actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('닫기'))]));
  }

  /* ───────── UI ───────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Children')),
        body: ListView.builder(
            itemCount: _children.length,
            itemBuilder: (_, i) {
              final c = _children[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical:4),
                child: ListTile(
                  leading: c.avatarPath!=null
                      ? CircleAvatar(backgroundImage: FileImage(File(c.avatarPath!)))
                      : const CircleAvatar(child: Icon(Icons.child_friendly)),
                  title: Text(c.name),
                  subtitle: Text('${c.age} years (${c.gender=='M'?'Boy':'Girl'})'),
                  trailing: _popup(i),
                  onLongPress: () => _editChild(i),
                  onTap:      () => _showRecommendedIntake(i),
                ),
              );
            }),
        floatingActionButton:
        FloatingActionButton(onPressed: _addChild, child: const Icon(Icons.add)));
  }

  PopupMenuButton<String> _popup(int i) {
    return PopupMenuButton<String>(
        onSelected: (v){
          switch(v){
            case 'record':        _recordMeal(i);       break;
            case 'record_photo':  _recordMealPhoto(i);  break;
            case 'view':          _viewMealPhotos(i);   break;
            case 'history':       _viewMealHistory(i);  break;
            case 'report':        _showNutritionReport(i); break;
          }},
        itemBuilder:(_)=>const[
          PopupMenuItem(value:'record',       child:Text('Record Meal')),
          PopupMenuItem(value:'record_photo', child:Text('Record Meal Photo')),
          PopupMenuItem(value:'view',         child:Text('View Meal Photos')),
          PopupMenuItem(value:'history',      child:Text('Meal History')),
          PopupMenuItem(value:'report',       child:Text('Nutrition Report')),
        ]);
  }

  void _showDeleteDialog(int i,String name){
    showDialog(
        context:context,
        builder:(_)=>AlertDialog(
            title:const Text('Delete Profile'),
            content:Text('Delete $name?'),
            actions:[
              TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),
              TextButton(onPressed:(){
                Navigator.pop(context);
                _deleteChild(i);
              },child:const Text('Delete')),
            ]));
  }
}
