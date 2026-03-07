import 'package:flutter/material.dart';
import '../../../api/feat/post_api.dart';
import '../../../models/post_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  late String _currentImageUrl;

  final Color primaryDark = const Color(0xFF1A1A2E);
  final Color accentOrange = const Color(0xFFF07B3F);

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.post.imageUrl;

    // Split caption into title and content (first line = title, rest = content)
    final caption = widget.post.caption ?? '';
    final lines = caption.split('\n');
    _titleController.text = lines.isNotEmpty ? lines.first : '';
    _contentController.text = lines.length > 1
        ? lines.sublist(1).join('\n')
        : '';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _submitEdit() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final postApi = PostApi();
      String? newImageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        newImageUrl = await postApi.uploadImage(_selectedImage!);
      }

      // Combine title and content
      final caption = _contentController.text.isNotEmpty
          ? "${_titleController.text}\n${_contentController.text}"
          : _titleController.text;

      await postApi.editPost(widget.post.id, caption, imageUrl: newImageUrl);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "EDIT POST",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildImageFrame(),
                const SizedBox(height: 24),
                _buildInputSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
        child: _buildSubmitButton(),
      ),
    );
  }

  Widget _buildImageFrame() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Show local file if picked, otherwise show network image
              if (_selectedImage != null)
                Image.file(_selectedImage!, fit: BoxFit.cover)
              else
                Image.network(
                  _currentImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              // Change image overlay button
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'เปลี่ยนรูป',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Reset to original image (if a new one was picked)
              if (_selectedImage != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImage = null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.undo,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            style: TextStyle(
              color: primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: "หัวข้อโพสต์ของคุณ",
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 121, 121, 121),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          TextField(
            controller: _contentController,
            maxLines: 6,
            style: TextStyle(
              color: primaryDark.withOpacity(0.8),
              fontSize: 15,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: "เขียนรายละเอียดเพิ่มเติม",
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 121, 121, 121),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitEdit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryDark.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "บันทึกการแก้ไข",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: Center(child: CircularProgressIndicator(color: accentOrange)),
    );
  }
}
