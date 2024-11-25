import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../Classes/overall.dart';
import '../Classes/user_info.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  XFile? _profileImage;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
      // Update the profile image in Overall
      final overall = Provider.of<Overall>(context, listen: false);
      overall.userInfo.setProfileImage(Image.file(File(image.path)));
      overall.updateUserInfo(overall.userInfo); // Save changes to SQLite
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit Profile'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/emback.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!.path))
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                    child: _profileImage == null
                        ? Icon(Icons.camera_alt, size: 50, color: Colors.indigo)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      final names = value.split(' ');
                      final firstName = names.isNotEmpty ? names[0] : '';
                      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
                      final overall = Provider.of<Overall>(context, listen: false);
                      overall.userInfo.setFirstName(firstName);
                      overall.userInfo.setLastName(lastName);
                    }
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(labelText: 'Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      final overall = Provider.of<Overall>(context, listen: false);
                      overall.userInfo.setPhoneNumber(value);
                    }
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save(); // Save the form to trigger onSaved
                      // Save profile information
                      final overall = Provider.of<Overall>(context, listen: false);
                      overall.updateUserInfo(overall.userInfo);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile updated')),
                      );
                    setState((){});
                    Navigator.pop(context, true);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}