import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';

class PassengerProfileScreen extends StatelessWidget {
  const PassengerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الملف الشخصي للراكب'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.stitchCobaltLight,
                    child: Icon(Icons.person, size: 36.sp, color: AppColors.stitchCobalt),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أحمد فتحي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '01012345678',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.stitchTealLight,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'راكب موثق • حساب مفعل',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.stitchTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Saved Stations Section
            _buildSectionHeader('المواقف والمعالم المفضلة'),
            SizedBox(height: 8.h),
            _buildStationItem(
              title: 'موقف الحصري',
              subtitle: 'نقطة الانطلاق اليومية للعمل',
              icon: Icons.home_outlined,
            ),
            SizedBox(height: 8.h),
            _buildStationItem(
              title: 'ميدان جهينة',
              subtitle: 'نقطة الوصول لجامعة ٦ أكتوبر',
              icon: Icons.work_outline,
            ),
            SizedBox(height: 16.h),

            // Recent Trips Section
            _buildSectionHeader('سجل الرحلات السابقة'),
            SizedBox(height: 8.h),
            _buildTripHistoryItem(
              date: 'أمس - 05:30 م',
              route: 'موقف الحصري ➔ ميدان جهينة',
              seats: '٢ كراسي (مشترك)',
              fare: '١٤ ج.م',
              driver: 'الأسطى محمد الشناوي',
            ),
            SizedBox(height: 8.h),
            _buildTripHistoryItem(
              date: '٢٢ سبتمبر - 08:15 ص',
              route: 'أول المدينة ➔ محور الكفراوي',
              seats: 'كرسي واحد',
              fare: '٧ ج.م',
              driver: 'كابتن ربيع السوهاجي',
            ),
            SizedBox(height: 20.h),

            // Logout / Switch Mode
            OutlinedButton.icon(
              onPressed: () {
                context.goNamed(AppRoute.driverDashboard.name);
              },
              icon: const Icon(Icons.airport_shuttle, color: AppColors.stitchCobalt),
              label: Text(
                'التبديل إلى وضع السائق',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.stitchCobalt,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.stitchCobalt),
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            TextButton.icon(
              onPressed: () {
                context.goNamed(AppRoute.login.name);
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildStationItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.stitchCobaltLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.stitchCobalt, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_left, color: AppColors.grey400),
        ],
      ),
    );
  }

  Widget _buildTripHistoryItem({
    required String date,
    required String route,
    required String seats,
    required String fare,
    required String driver,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  color: AppColors.grey600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.stitchAmberLight,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  fare,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onAmber,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            route,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '$driver • $seats',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
