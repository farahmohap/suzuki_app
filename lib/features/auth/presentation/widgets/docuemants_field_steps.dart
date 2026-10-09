import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:suzuki_app/core/constants/app_colors.dart';

class DocumentsFieldsStep extends StatefulWidget {
  const DocumentsFieldsStep({super.key});

  @override
  State<DocumentsFieldsStep> createState() => _DocumentsFieldsStepState();
}

class _DocumentsFieldsStepState extends State<DocumentsFieldsStep> {
  final Map<String, XFile?> _docs = {
    'nationalId': null,
    'drivingLicense': null,
    'vehicleLicense': null,
    'criminalRecord': null,
  };

  Future<void> _pickDocument(String key) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _docs[key] = picked);
    }
  }

  void _removeDocument(String key) {
    setState(() => _docs[key] = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // 👈 يضمن عدم التمدد اللا نهائي
      children: [
        _buildDocumentTile(
          'بطاقة الرقم القومي (الوجهان)',
          Icons.credit_card,
          'nationalId',
        ),
        SizedBox(height: 8.h),
        _buildDocumentTile(
          'رخصة القيادة (مهنية / خاصة)',
          Icons.contact_emergency,
          'drivingLicense',
        ),
        SizedBox(height: 8.h),
        _buildDocumentTile(
          'رخصة تسيير السوزوكي',
          Icons.drive_eta,
          'vehicleLicense',
        ),
        SizedBox(height: 8.h),
        _buildDocumentTile(
          'صحيفة الحالة الجنائية (الفيش والتشبيه)',
          Icons.verified,
          'criminalRecord',
        ),
      ],
    );
  }

  Widget _buildDocumentTile(String title, IconData icon, String key) {
    final isUploaded = _docs[key] != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon & Title Box
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Actions Box (رفع / حذف + تم الرفع)
          if (isUploaded)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _removeDocument(key),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.check_circle, color: Colors.green, size: 18.sp),
              ],
            )
          else
            SizedBox(
              height: 32.h,
              width: 60.w,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: () => _pickDocument(key),
                child: Text(
                  'رفع',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
