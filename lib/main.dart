import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: ProfileSettingsPage(),
  ));
}

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _age = 5;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('child_name') ?? '';
      _age = prefs.getInt('child_age') ?? 5;
      final avatarPath = prefs.getString('child_avatar');
      if (avatarPath != null && File(avatarPath).existsSync()) {
        _avatarImage = File(avatarPath);
      }
    });
  }

  Future<void> _pickAvatar() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('child_name', _name);
      await prefs.setInt('child_age', _age);
      if (_avatarImage != null) {
        await prefs.setString('child_avatar', _avatarImage!.path);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Profile Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _avatarImage != null
                        ? FileImage(_avatarImage!)
                        : const AssetImage('assets/avatar_placeholder.png') as ImageProvider,
                    child: _avatarImage == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Age', style: TextStyle(fontSize: 16)),
                  DropdownButton<int>(
                    value: _age,
                    items: List.generate(
                      100,
                          (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1} years'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) setState(() => _age = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
