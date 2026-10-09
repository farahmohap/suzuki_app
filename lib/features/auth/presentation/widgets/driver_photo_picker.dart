import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DriverPhotoPicker extends StatelessWidget {
  final XFile? imageFile;
  final ValueChanged<XFile?> onImageSelected;

  const DriverPhotoPicker({
    super.key,
    required this.imageFile,
    required this.onImageSelected,
  });

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      onImageSelected(picked);
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (imageFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف الصورة', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  onImageSelected(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: const Color(0xFFDDE1FF),
                backgroundImage: imageFile != null ? FileImage(File(imageFile!.path)) : null,
                child: imageFile == null
                    ? const Icon(Icons.person, size: 48, color: Color(0xFF00288E))
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showOptions(context),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF00288E),
                    child: Icon(Icons.camera_alt, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            imageFile != null ? 'انقر لتغيير أو حذف الصورة' : 'الصورة الشخصية للكابتن *',
            style: const TextStyle(fontSize: 11, color: Color(0xFF757684)),
          ),
        ],
      ),
    );
  }
}