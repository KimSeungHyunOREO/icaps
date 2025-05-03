// lib/screens/profile_settings_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/models/child_profile.dart';   // ← 모델 import
//   untitled → 프로젝트 이름

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
    if (p?.avatarPath != null) _avatar = File(p!.avatarPath!);
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
    );
    if (file != null) setState(() => _avatar = File(file.path));
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
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
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Add Child' : 'Edit Child'),
      ),
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
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Age'),
                  DropdownButton<int>(
                    value: _age,
                    items: List.generate(
                      100,
                          (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1} years'),
                      ),
                    ),
                    onChanged: (v) => setState(() => _age = v!),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
