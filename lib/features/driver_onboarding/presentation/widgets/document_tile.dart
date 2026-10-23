import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../cubit/driver_onboarding_cubit.dart';

/// Big, simple upload tile (driver-friendly: large target, one action).
/// Reused by the wizard (step 3) and the rejected-document flow.
class DocumentTile extends StatelessWidget {
  const DocumentTile({
    super.key,
    required this.label,
    required this.icon,
    required this.slot,
    required this.onPicked,
    this.onRemove,
    this.rejectReason,
    this.useCamera = false,
  });

  final String label;
  final IconData icon;
  final DocSlot slot;
  final ValueChanged<String> onPicked;
  final VoidCallback? onRemove;
  final String? rejectReason;
  final bool useCamera;

  Future<void> _pick(BuildContext context) async {
    final source = useCamera
        ? ImageSource.camera
        : await showModalBottomSheet<ImageSource>(
            context: context,
            builder: (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('الكاميرا'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('المعرض'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
          );
    if (source == null) return;
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file != null) onPicked(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final uploading = slot.status == DocUploadStatus.uploading;
    final done = slot.status == DocUploadStatus.uploaded;
    final failed = slot.status == DocUploadStatus.failed;
    final color = done
        ? Colors.green.shade700
        : (failed || rejectReason != null)
            ? AppColors.error
            : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: uploading ? null : () => _pick(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (slot.localPath != null && !failed)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(slot.localPath!),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Icon(icon, size: 40, color: color),
                      ),
                    )
                  else
                    Icon(icon, size: 40, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (done) Icon(Icons.check_circle, color: color, size: 30),
                  if (!done && !uploading)
                    Icon(Icons.add_a_photo_outlined, color: color, size: 28),
                  if (done && onRemove != null)
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.close),
                      tooltip: 'حذف',
                    ),
                ],
              ),
              if (uploading) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: slot.progress == 0 ? null : slot.progress,
                ),
              ],
              if (failed)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'فشل الرفع — اضغط للمحاولة مرة أخرى',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              if (rejectReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'سبب الرفض: $rejectReason',
                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
