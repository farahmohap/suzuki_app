import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/osm_map_widget.dart';

class DriverTripScreen extends StatefulWidget {
  const DriverTripScreen({super.key,required this.tripId});

  final String tripId;

  @override
  State<DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends State<DriverTripScreen> {
  static const LatLng _vanPosition = LatLng(29.9980, 30.9550);
  final int _collectedCash = 35; // 5 seats * 7 EGP

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الرحلة الحالية - السائق'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Live Map Header
          Expanded(
            flex: 3,
            child: OsmMapWidget(
              initialCenter: _vanPosition,
              initialZoom: 14.0,
              vans: const [
                OsmVanMarker(
                  id: 'van_me',
                  driverName: 'عربيتي (في الطريق)',
                  availableSeats: 2,
                  point: _vanPosition,
                ),
              ],
            ),
          ),

          // Trip Controls Panel
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Fare Counter Card
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColors.stitchTealLight,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.payments_outlined, color: AppColors.stitchTeal),
                              SizedBox(width: 8.w),
                              Text(
                                'إجمالي الأجرة المحصلة كاش:',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.stitchTeal,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$_collectedCash ج.م',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.stitchTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Next Drop-off Station Alert
                    Text(
                      'المحطة القادمة:',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: AppColors.grey600,
                      ),
                    ),
                    Text(
                      'ميدان جهينة (نزول ٣ ركاب)',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Finish Trip Action
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إنهاء الرحلة بنجاح!')),
                        );
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'إنهاء الرحلة والوصول للموقف',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}