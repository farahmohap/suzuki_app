import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/driver_badge_card.dart';
import '../../../../core/widgets/osm_map_widget.dart';

class ActiveTrackingScreen extends StatelessWidget {
  const ActiveTrackingScreen({super.key, required this.bookingId});

  final String bookingId;

  static const LatLng _startPoint = LatLng(29.9869, 30.9416); // الحصري
  static const LatLng _currentVan = LatLng(29.9980, 30.9550); // وسط الطريق
  static const LatLng _endPoint = LatLng(30.0125, 30.9701); // جهينة

  static const List<LatLng> _routePoints = [
    LatLng(29.9869, 30.9416),
    LatLng(29.9920, 30.9480),
    LatLng(29.9980, 30.9550),
    LatLng(30.0050, 30.9630),
    LatLng(30.0125, 30.9701),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تتبع الرحلة المباشر'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Live Map Header
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                OsmMapWidget(
                  initialCenter: _currentVan,
                  initialZoom: 14.0,
                  routePoints: _routePoints,
                  stations: const [
                    OsmStationMarker(
                      id: 's_start',
                      title: 'موقف الحصري (ركوب)',
                      point: _startPoint,
                      isHub: true,
                    ),
                    OsmStationMarker(
                      id: 's_end',
                      title: 'ميدان جهينة (نزول)',
                      point: _endPoint,
                      isHub: true,
                    ),
                  ],
                  vans: const [
                    OsmVanMarker(
                      id: 'v_active',
                      driverName: 'الأسطى محمد',
                      availableSeats: 2,
                      point: _currentVan,
                    ),
                  ],
                ),

                // Floating ETA Banner
                Positioned(
                  top: 14.h,
                  right: 14.w,
                  left: 14.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.stitchCobalt,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.stitchCobalt.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer, color: AppColors.stitchAmberLight, size: 20),
                            SizedBox(width: 8.w),
                            Text(
                              'الوقت المتبقي للوصول:',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '٥ دقائق تقريبًا',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.stitchAmberLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trip Progress & Action Details
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Driver info card
                    const DriverBadgeCard(),
                    SizedBox(height: 12.h),

                    // Quick Action Buttons (Call / WhatsApp)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.phone, color: AppColors.stitchCobalt),
                            label: Text(
                              'اتصال بالسائق',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.stitchCobalt),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.chat, color: AppColors.stitchTeal),
                            label: Text(
                              'محادثة سريعة',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.stitchTeal),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Stations Progress Timeline
                    Text(
                      'خط سير الرحلة والمحطات',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildTimelineStep(
                      title: 'موقف الحصري (محطة الانطلاق)',
                      subtitle: 'تم التحرك في تمام الساعة 02:15 م',
                      isCompleted: true,
                    ),
                    _buildTimelineStep(
                      title: 'محور الكفراوي / الحي الثاني',
                      subtitle: 'السوزوكي عبر هذه النقطة',
                      isCompleted: true,
                    ),
                    _buildTimelineStep(
                      title: 'ميدان جهينة (محطة الوصول)',
                      subtitle: 'الوصول المتوقع 02:28 م',
                      isCompleted: false,
                      isLast: true,
                    ),
                    SizedBox(height: 12.h),

                    // Fare reminder
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الأجرة المطلوب دفعها عند النزول:',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '١٤ ج.م (كاش)',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.stitchCobalt,
                            ),
                          ),
                        ],
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

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.stitchCobalt : Colors.white,
                  border: Border.all(
                    color: isCompleted ? AppColors.stitchCobalt : AppColors.grey400,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 8, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: isCompleted ? AppColors.stitchCobalt : AppColors.grey200,
                  ),
                ),
            ],
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppColors.onSurface : AppColors.grey600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.sp,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
