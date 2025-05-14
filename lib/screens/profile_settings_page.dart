// lib/screens/profile_settings_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/child_profile.dart';

class ProfileSettingsPage extends StatefulWidget {
  final ChildProfile? profile;
  const ProfileSettingsPage({super.key, this.profile});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  File? _avatar;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late int _age;
  late double _height;
  late double _weight;
  String _gender = 'M';

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = p?.name ?? '';
    _age = p?.age ?? 5;
    _height = p?.height ?? 100;
    _weight = p?.weight ?? 20;
    _gender = p?.gender ?? 'M';
    if (p?.avatarPath != null) _avatar = File(p!.avatarPath!);
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _avatar = File(file.path));
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      Navigator.pop(
        context,
         ChildProfile(
          name: _name,
          age: _age,
          height: _height,
          weight: _weight,
          gender: _gender,
          avatarPath: _avatar?.path,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Add Child' : 'Edit Child'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 아바타
              GestureDetector(
                onTap: _pickAvatar,
                child: _avatar != null
                    ? CircleAvatar(radius: 60, backgroundImage: FileImage(_avatar!))
                    : const CircleAvatar(radius: 60, child: Icon(Icons.camera_alt)),
              ),
              const SizedBox(height: 24),

              // 이름
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 16),

              // 나이 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Age'),
                  DropdownButton<int>(
                    value: _age,
                    items: List.generate(
                      100,
                          (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                    ),
                    onChanged: (v) => setState(() => _age = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 키
              TextFormField(
                initialValue: _height.toString(),
                decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter height' : null,
                onSaved: (v) => _height = double.parse(v!),
              ),
              const SizedBox(height: 16),

              // 몸무게
              TextFormField(
                initialValue: _weight.toString(),
                decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter weight' : null,
                onSaved: (v) => _weight = double.parse(v!),
              ),
              const SizedBox(height: 16),

              // 성별
              Row(
                children: [
                  const Text('Gender:'),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Boy')),
                      DropdownMenuItem(value: 'F', child: Text('Girl')),
                    ],
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 저장
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
