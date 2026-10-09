import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VehiclePhotosStep extends StatefulWidget {
  const VehiclePhotosStep({super.key});

  @override
  State<VehiclePhotosStep> createState() => _VehiclePhotosStepState();
}

class _VehiclePhotosStepState extends State<VehiclePhotosStep> {
  XFile? _frontPhoto;
  XFile? _backPhoto;
  XFile? _interiorPhoto;

  Future<void> _pickPhoto(Function(XFile) onPicked) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التقط أو اختر صور السوزوكي الواضحة:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildPhotoTile(
                'الواجهة الأمامية',
                Icons.directions_car,
                _frontPhoto,
                (p) => setState(() => _frontPhoto = p),
                () => setState(() => _frontPhoto = null),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPhotoTile(
                'الجهة الخلفية',
                Icons.directions_car_filled,
                _backPhoto,
                (p) => setState(() => _backPhoto = p),
                () => setState(() => _backPhoto = null),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPhotoTile(
                'الفرش (٧ كراسي)',
                Icons.airline_seat_recline_normal,
                _interiorPhoto,
                (p) => setState(() => _interiorPhoto = p),
                () => setState(() => _interiorPhoto = null),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoTile(
    String label,
    IconData icon,
    XFile? file,
    Function(XFile) onSet,
    VoidCallback onRemove,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4C5D5)),
      ),
      child: Column(
        children: [
          if (file != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(file.path), height: 40, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                  ),
                ),
              ],
            )
          else
            Icon(icon, size: 28, color: const Color(0xFF00288E)),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _pickPhoto(onSet),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF00288E), borderRadius: BorderRadius.circular(6)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(file != null ? Icons.edit : Icons.camera_alt, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(file != null ? 'تعديل' : 'التقاط', style: const TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}