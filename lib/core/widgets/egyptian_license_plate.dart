import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

/// Authentic Egyptian vehicle license plate widget.
/// Example: "5 4 8 2 | ق ن ص" with blue "مصر / EGYPT" header.
class EgyptianLicensePlate extends StatelessWidget {
  const EgyptianLicensePlate({
    super.key,
    this.numbers = '٥ ٤ ٨ ٢',
    this.letters = 'ق ن ص',
  });

  final String numbers;
  final String letters;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.plateBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.plateBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Country Brand Side (مصر / EGYPT)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.plateHeaderBlue,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(6.r),
                  bottomRight: Radius.circular(6.r),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'مصر',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'EGYPT',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            // Plate Digits & Letters
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    numbers,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurface,
                      letterSpacing: 2,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Container(
                      width: 1.5,
                      height: 18.h,
                      color: AppColors.plateBorder,
                    ),
                  ),
                  Text(
                    letters,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurface,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
