import 'package:flutter/material.dart';
import '../../../../api/feat/post_api.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  Future<void> _submitPost() async {
    if (_isLoading) return;

    // ตรวจสอบว่ากรอกเนื้อหา
    if (_contentController.text.isEmpty) {
      debugPrint('[CreatePostScreen] Empty content validation failed');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณากรอกเนื้อหาโพสต์")));
      return;
    }

    // ตรวจสอบว่าเลือกรูปภาพ (บังคับ)
    if (_selectedImage == null) {
      debugPrint('[CreatePostScreen] No image selected');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาเลือกรูปภาพ")));
      return;
    }

    setState(() => _isLoading = true);

    debugPrint('[CreatePostScreen] Starting image upload...');

    try {
      // 1. อัพโหลดรูปภาพก่อน
      final postApi = PostApi();
      final imageUrl = await postApi.uploadImage(_selectedImage!);

      debugPrint('[CreatePostScreen] Image uploaded successfully: $imageUrl');
      debugPrint(
        '[CreatePostScreen] Creating post with caption: ${_contentController.text}',
      );

      // 2. สร้างโพสต์พร้อม URL รูปภาพ
      await postApi.createPost(
        caption: _contentController.text,
        image_url: imageUrl,
      );

      if (!mounted) return;
      debugPrint('[CreatePostScreen] Post created successfully');
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('[CreatePostScreen] Error creating post: $e');
      String errorMessage = "เกิดข้อผิดพลาด";

      // แสดงข้อความ error ที่เฉพาะเจาะจง
      if (e.toString().contains('No file uploaded')) {
        errorMessage = "ไม่สามารถอัพโหลดรูปภาพได้";
      } else if (e.toString().contains('Invalid file type')) {
        errorMessage = "ประเภทไฟล์ไม่รองรับ กรุณาเลือกไฟล์รูปภาพ";
      } else if (e.toString().contains('file too large')) {
        errorMessage = "ขนาดไฟล์ใหญ่เกินไป (สูงสุด 5MB)";
      } else if (e.toString().contains('User not logged in')) {
        errorMessage = "กรุณาเข้าสู่ระบบใหม่";
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // ฟังก์ชันลบรูปภาพที่เลือก
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("สร้างโพสต์")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "หัวข้อโพสต์",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: "เนื้อหาโพสต์",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Image selection area
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: _selectedImage == null
                  ? GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'เลือกรูปภาพ',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'จำเป็นต้องมีรูปภาพ',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'เลือกรูปภาพใหม่',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            if (_selectedImage != null)
              GestureDetector(
                onTap: _pickImage,
                child: const SizedBox(width: double.infinity, height: 200),
              ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("โพสต์"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
