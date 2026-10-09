import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suzuki_app/features/auth/data/models/auth_model.dart';
import 'driver_photo_picker.dart';

class PersonalFieldsStep extends StatelessWidget {
  final DriverRegistrationModel formData;
  final ValueChanged<XFile?> onPhotoChanged;

  const PersonalFieldsStep({
    super.key,
    required this.formData,
    required this.onPhotoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DriverPhotoPicker(
          imageFile: formData.driverPhoto,
          onImageSelected: onPhotoChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: formData.fullName,
          decoration: const InputDecoration(
            labelText: 'الاسم بالكامل (كما بالبطاقة)',
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => formData.fullName = v,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: formData.phoneNumber,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم الموبايل',
            prefixIcon: Icon(Icons.phone_iphone),
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => formData.phoneNumber = v,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: formData.age.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'السن',
                  suffixText: 'سنة',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => formData.age = int.tryParse(v) ?? 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<Gender>(
                value: formData.gender,
                decoration: const InputDecoration(
                  labelText: 'النوع',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: Gender.male, child: Text('ذكر')),
                  DropdownMenuItem(value: Gender.female, child: Text('أنثى')),
                ],
                onChanged: (val) {
                  if (val != null) formData.gender = val;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}