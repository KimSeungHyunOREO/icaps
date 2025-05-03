// lib/main.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/food_search_page.dart';

import 'service/language_service.dart';
import 'meal_history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyAppWrapper(),
    ),
  );
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageService(),
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context);
    return MaterialApp(
      title: 'Star Plate',
      theme: ThemeData(primarySwatch: Colors.green),
      locale: lang.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: const HomePage(),
    );
  }
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('menu'.tr())),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[200]),
              child: const Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.child_care),
              title: Text('Child Profiles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildrenListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('식품 성분 검색'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FoodSearchPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const LanguageSelector(),
                );
              },
            ),
          ],
        ),
      ),

      body: Center(child: Text('select_menu'.tr())),
    );
  }
}

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context);
    return AlertDialog(
      title: Text('language'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<Locale>(
            value: const Locale('en'),
            groupValue: lang.locale,
            title: const Text('English'),
            onChanged: (val) {
              if (val != null) lang.setLocale(context, val);
            },
          ),
          RadioListTile<Locale>(
            value: const Locale('ko'),
            groupValue: lang.locale,
            title: const Text('한국어'),
            onChanged: (val) {
              if (val != null) lang.setLocale(context, val);
            },
          ),
        ],
      ),
    );
  }
}




/// Model: Child Profile
class ChildProfile {
  String name;
  int age;
  String? avatarPath;

  ChildProfile({required this.name, required this.age, this.avatarPath});

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
    name: json['name'],
    age: json['age'],
    avatarPath: json['avatarPath'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'avatarPath': avatarPath,
  };
}

/// Model: Meal Photo
class MealPhoto {
  String childName;
  String date; // YYYY-MM-DD
  String mealType;
  String imagePath;

  MealPhoto({
    required this.childName,
    required this.date,
    required this.mealType,
    required this.imagePath,
  });

  factory MealPhoto.fromJson(Map<String, dynamic> json) => MealPhoto(
    childName: json['childName'],
    date: json['date'],
    mealType: json['mealType'],
    imagePath: json['imagePath'],
  );

  Map<String, dynamic> toJson() => {
    'childName': childName,
    'date': date,
    'mealType': mealType,
    'imagePath': imagePath,
  };
}

/// Page: Children List / Profile Management
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
          builder: (_) => MealPhotoPage(childName: _children[i].name)),
    );
  }

  void _viewMealPhotos(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => MealPhotoListPage(childName: _children[i].name)),
    );
  }

  void _viewMealHistory(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MealHistoryPage(childName: _children[i].name),
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
                  ? CircleAvatar(
                  backgroundImage: FileImage(File(c.avatarPath!)))
                  : const CircleAvatar(child: Icon(Icons.child_friendly)),
              title: Text(c.name),
              subtitle: Text('${c.age} years'),
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Profile'),
                    content: Text('Delete profile for ${c.name}?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteChild(i);
                          },
                          child: const Text('Delete'))
                    ],
                  ),
                );
              },
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      _viewMealPhotos(i);
                      break;
                    case 'record':
                      _recordMealPhoto(i);
                      break;
                    case 'edit':
                      _editChild(i);
                      break;
                    case 'history':
                      _viewMealHistory(i);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'view', child: Text('View Meal Photos')),
                  const PopupMenuItem(
                      value: 'record', child: Text('Record Meal')),
                  const PopupMenuItem(
                      value: 'edit', child: Text('Edit Profile')),
                  const PopupMenuItem(
                      value: 'history', child: Text('Meal History')),
                ],
              ),
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
}

/// Page: Add/Edit Child
class ProfileSettingsPage extends StatefulWidget {
  final ChildProfile? profile;
  const ProfileSettingsPage({super.key, this.profile});
  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  File? _avatar;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _age;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = p?.name ?? '';
    _age = p?.age ?? 5;
    final path = p?.avatarPath;
    if (path != null) _avatar = File(path);
  }

  Future<void> _pickAvatar() async {
    final file =
    await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600);
    if (file != null) setState(() => _avatar = File(file.path));
  }

  void _save() {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState!.save();
      Navigator.pop(
        context,
        ChildProfile(name: _name, age: _age, avatarPath: _avatar?.path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(widget.profile == null ? 'Add Child' : 'Edit Child')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickAvatar,
                child: _avatar != null
                    ? CircleAvatar(radius: 60, backgroundImage: FileImage(_avatar!))
                    : const CircleAvatar(radius: 60, child: Icon(Icons.camera_alt)),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter a name' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Age'),
                DropdownButton<int>(
                  value: _age,
                  items: List.generate(
                      100, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1} years'))),
                  onChanged: (v) => setState(() => _age = v!),
                )
              ]),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page: Record Meal Photo
class MealPhotoPage extends StatefulWidget {
  final String childName;
  const MealPhotoPage({super.key, required this.childName});
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
        '${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    final prefs = await SharedPreferences.getInstance();
    final key = 'meal_photos';
    final stored = prefs.getStringList(key) ?? [];
    final photo = MealPhoto(
        childName: widget.childName,
        date: date,
        mealType: _selectedMeal.toLowerCase(),
        imagePath: _image!.path);
    final updated = stored.where((e) {
      final m = MealPhoto.fromJson(jsonDecode(e));
      return !(m.childName == photo.childName &&
          m.date == photo.date &&
          m.mealType == photo.mealType);
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
        child: Column(children: [
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
              child:
              const Center(child: Icon(Icons.camera_alt, size: 50)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _savePhoto, child: const Text('Save Photo')),
        ]),
      ),
    );
  }
}

/// Page: View Today's Meal Photos
class MealPhotoListPage extends StatefulWidget {
  final String childName;
  const MealPhotoListPage({super.key, required this.childName});
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
        '${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
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
        itemBuilder: (c, i) {
          final m = _photos[i];
          return ListTile(
            leading: Image.file(File(m.imagePath),
                width: 50, height: 50, fit: BoxFit.cover),
            title: Text(
                '${m.mealType[0].toUpperCase()}${m.mealType.substring(1)}'),
          );
        },
      ),
    );
  }
}
