import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import 'egyptian_license_plate.dart';

class DriverBadgeCard extends StatelessWidget {
  const DriverBadgeCard({
    super.key,
    this.driverName = 'الأسطى محمد الشناوي',
    this.rating = 4.9,
    this.tripsCount = 140,
    this.vanInfo = 'سوزوكي فان • سعة ٧ ركاب',
    this.plateNumbers = '٥ ٤ ٨ ٢',
    this.plateLetters = 'ق ن ص',
    this.hubCertification = 'معتمد من موقف أكتوبر',
    this.avatarUrl,
  });

  final String driverName;
  final double rating;
  final int tripsCount;
  final String vanInfo;
  final String plateNumbers;
  final String plateLetters;
  final String hubCertification;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Driver Avatar, Rating & Basic Info
          Row(
            children: [
              // Avatar with verified badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: AppColors.stitchCobaltLight,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    child: avatarUrl == null
                        ? Icon(Icons.person, size: 32.sp, color: AppColors.stitchCobalt)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified,
                        color: AppColors.stitchCobalt,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),

              // Name and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'كابتن الخط',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                        // Rating Pill
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: AppColors.stitchAmber, size: 14),
                              SizedBox(width: 3.w),
                              Text(
                                '$rating',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                '($tripsCount رحلة)',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10.sp,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      driverName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.directions_car, size: 13.sp, color: AppColors.stitchCobalt),
                        SizedBox(width: 4.w),
                        Text(
                          vanInfo,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // License Plate & Station Certification Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EgyptianLicensePlate(
                numbers: plateNumbers,
                letters: plateLetters,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.stitchTealLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, color: AppColors.stitchTeal, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      hubCertification,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.stitchTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
