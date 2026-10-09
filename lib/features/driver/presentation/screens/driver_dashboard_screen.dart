import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/egyptian_license_plate.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = true;
  String _selectedRoute = 'خط الحصري - ميدان جهينة';
  int _occupiedSeats = 4; // 4 out of 7 seats filled

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة تحكم السائق'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Navigate to Driver Profile / Switch back to passenger
              context.goNamed(AppRoute.passengerHome.name);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Driver Status & Online Toggle
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _isOnline ? AppColors.stitchTeal : AppColors.grey400,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: _isOnline ? AppColors.stitchTealLight : AppColors.grey200,
                    child: Icon(
                      _isOnline ? Icons.directions_bus : Icons.bus_alert,
                      color: _isOnline ? AppColors.stitchTeal : AppColors.grey600,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOnline ? 'حالة السائق: جاهز للتحميل' : 'حالة السائق: أوفلاين',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          _isOnline ? 'متواجد في دور موقف الحصري' : 'قم بالتفعيل لبدء رحلات اليوم',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isOnline,
                    activeColor: AppColors.stitchTeal,
                    onChanged: (val) => setState(() => _isOnline = val),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Vehicle Plate & Line Selector
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'بيانات العربية والخط',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const EgyptianLicensePlate(),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRoute,
                        isExpanded: true,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'خط الحصري - ميدان جهينة',
                            child: Text('خط الحصري - ميدان جهينة (٧ ج.م)'),
                          ),
                          DropdownMenuItem(
                            value: 'خط أول المدينة - محور الكفراوي',
                            child: Text('خط أول المدينة - محور الكفراوي (٦ ج.م)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRoute = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Cabin Seat Capacity Status
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إشغال الكراسي الحالي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_occupiedSeats / ٧ كراسي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.stitchCobalt,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  LinearProgressIndicator(
                    value: _occupiedSeats / 7,
                    backgroundColor: AppColors.grey200,
                    color: AppColors.stitchCobalt,
                    minHeight: 10.h,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: _occupiedSeats > 0
                            ? () => setState(() => _occupiedSeats--)
                            : null,
                        child: const Text('نزول راكب (-)'),
                      ),
                      ElevatedButton(
                        onPressed: _occupiedSeats < 7
                            ? () => setState(() => _occupiedSeats++)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.stitchCobalt,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('ركوب راكب (+)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Start Trip Button
            ElevatedButton.icon(
              onPressed: _isOnline
                  ? () {
                      context.pushNamed(
                        AppRoute.driverTrip.name,
                        pathParameters: {'tripId': 'trip_active_909'},
                      );
                    }
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                'بدء التحرك على الخط',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.stitchCobalt,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}