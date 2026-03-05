import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../api/feat/auth_service.dart';
import '../../../api/api_service.dart';
import '../../../models/user_model.dart';
import '../../../core/storage/token_storage.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _profileImageUrl;
  XFile? _pickedImage;
  bool _isLoading = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _bioController.text = widget.user.bio ?? '';
    _profileImageUrl = widget.user.profileImage;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
          _imageChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถเลือกรูปภาพได้')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กรุณาเข้าสู่ระบบใหม่อีกครั้ง'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      String? profileImageToUpload = _profileImageUrl;

      // Upload new image file first, then get the returned URL
      if (_imageChanged && _pickedImage != null) {
        profileImageToUpload = await _uploadImageFile(_pickedImage!);
      }

      await _authService.editProfile(
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        profileImage: profileImageToUpload,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('อัปเดตโปรไฟล์สำเร็จ')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'ไม่สามารถอัปเดตโปรไฟล์ได้: ${e.toString()}';
        if (e.toString().contains('Username already taken')) {
          errorMessage = 'ชื่อผู้ใช้นี้ถูกใช้ไปแล้ว';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Uploads [image] to the server and returns its public URL.
  Future<String?> _uploadImageFile(XFile image) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('ไม่พบ token');

    final uri = Uri.parse('${ApiService.baseURL}/api/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('อัปโหลดรูปภาพล้มเหลว (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['success'] != true || decoded['imageUrl'] == null) {
      throw Exception(decoded['message'] ?? 'อัปโหลดรูปภาพล้มเหลว');
    }

    return decoded['imageUrl'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขโปรไฟล์'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('บันทึก'),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _pickedImage != null
                          ? FileImage(File(_pickedImage!.path)) as ImageProvider
                          : _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _pickedImage == null && _profileImageUrl == null
                          ? const Icon(
                              Icons.person_2_rounded,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF07B3F),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อผู้ใช้',
                  hintText: 'กรอกชื่อผู้ใช้',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อผู้ใช้';
                  }
                  if (value.trim().length < 3) {
                    return 'ชื่อผู้ใช้ต้องมีอย่างน้อย 3 ตัวอักษร';
                  }
                  if (value.trim().length > 20) {
                    return 'ชื่อผู้ใช้ต้องไม่เกิน 20 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Bio Field
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'ประวัติ',
                  hintText: 'เขียนประวัติส่วนตัว',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 3,
                maxLength: 150,
                validator: (value) {
                  if (value != null && value.trim().length > 150) {
                    return 'ประวัติต้องไม่เกิน 150 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text('ยกเลิก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
