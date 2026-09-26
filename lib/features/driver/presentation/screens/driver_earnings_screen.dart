import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('أرباح السائق والاشتراك'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Primary Earnings Card
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.stitchCobalt, Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.stitchCobalt.withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إجمالي تحصيل اليوم (كاش)',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.stitchAmber,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '٢٨ رحلة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '٤٢٠',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'جنيه مصري',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.stitchAmberLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'اشتراك الموقف الشهري:',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'ساري حتى ٣٠ أكتوبر',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.stitchAmberLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Performance Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'أرباح الأسبوع',
                    value: '٢,٨٥٠ ج.م',
                    icon: Icons.trending_up,
                    color: AppColors.stitchTeal,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildMetricTile(
                    title: 'نسبة إشغال الكراسي',
                    value: '٨٩ ٪',
                    icon: Icons.airline_seat_recline_normal,
                    color: AppColors.stitchAmber,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // Trips Ledger
            Text(
              'تفاصيل رحلات اليوم',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: 8.h),

            _buildLedgerItem(
              time: '02:15 م',
              route: 'موقف الحصري ➔ ميدان جهينة',
              fare: '٤٩ ج.م',
              seatsOccupied: '٧ / ٧ كراسي (ممتلئة)',
            ),
            SizedBox(height: 8.h),
            _buildLedgerItem(
              time: '01:30 م',
              route: 'ميدان جهينة ➔ موقف الحصري',
              fare: '٣٥ ج.م',
              seatsOccupied: '٥ / ٧ كراسي',
            ),
            SizedBox(height: 8.h),
            _buildLedgerItem(
              time: '12:45 م',
              route: 'الحصري ➔ محور الكفراوي',
              fare: '٤٢ ج.م',
              seatsOccupied: '٦ / ٧ كراسي',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerItem({
    required String time,
    required String route,
    required String fare,
    required String seatsOccupied,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey800,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    seatsOccupied,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.sp,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            fare,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.stitchCobalt,
            ),
          ),
        ],
      ),
    );
  }
}
