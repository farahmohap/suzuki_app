import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/osm_map_widget.dart';
import '../../../../core/widgets/station_chips_bar.dart';
import '../../../../core/widgets/egyptian_license_plate.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStation = 'موقف الحصري';

  final List<String> _stations = [
    'موقف الحصري',
    'ميدان جهينة',
    'محور 26 يوليو',
    'موقف أول المدينة',
    'موقف الحي العاشر',
    'الشيخ زايد - هايبر',
  ];

  // 6th of October City / Cairo Landmark coordinates
  static const LatLng _octoberCenter = LatLng(29.9869, 30.9416);

  final List<OsmStationMarker> _stationMarkers = const [
    OsmStationMarker(
      id: 'st_1',
      title: 'موقف الحصري',
      point: LatLng(29.9869, 30.9416),
      isHub: true,
    ),
    OsmStationMarker(
      id: 'st_2',
      title: 'ميدان جهينة',
      point: LatLng(30.0125, 30.9701),
      isHub: true,
    ),
    OsmStationMarker(
      id: 'st_3',
      title: 'محور 26 يوليو',
      point: LatLng(30.0245, 30.9950),
    ),
  ];

  final List<OsmVanMarker> _nearbyVans = const [
    OsmVanMarker(
      id: 'van_1',
      driverName: 'الأسطى محمد الشناوي',
      availableSeats: 3,
      point: LatLng(29.9880, 30.9430),
    ),
    OsmVanMarker(
      id: 'van_2',
      driverName: 'عم ربيع السوهاجي',
      availableSeats: 2,
      point: LatLng(29.9850, 30.9390),
    ),
    OsmVanMarker(
      id: 'van_3',
      driverName: 'كابتن محمود الباشا',
      availableSeats: 5,
      point: LatLng(30.0050, 30.9600),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Header / Brand & Search Bar ──────────────────────────────
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.h,
                            decoration: BoxDecoration(
                              color: AppColors.stitchCobalt,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: const Icon(
                              Icons.airport_shuttle,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سوزوكي',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.stitchCobalt,
                                  height: 1.1,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 12.sp, color: AppColors.stitchAmber),
                                  SizedBox(width: 2.w),
                                  Text(
                                    '٦ أكتوبر • الشيخ زايد',
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
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Badge(
                          smallSize: 8,
                          backgroundColor: AppColors.stitchAmber,
                          child: Icon(Icons.notifications_none, color: AppColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Destination Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.stitchCobalt),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              color: AppColors.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'رايح أنهي موقف أو حي؟',
                              hintStyle: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                color: AppColors.grey600,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: AppColors.stitchAmberLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.tune,
                            size: 16.sp,
                            color: AppColors.stitchAmber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Station Chips Bar ────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.only(bottom: 12.h),
              child: StationChipsBar(
                stations: _stations,
                selectedStation: _selectedStation,
                onStationSelected: (station) {
                  setState(() => _selectedStation = station);
                },
              ),
            ),

            // ── Map & Nearby Vans List ───────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  // OpenStreetMap container
                  Positioned.fill(
                    child: OsmMapWidget(
                      initialCenter: _octoberCenter,
                      initialZoom: 13.5,
                      stations: _stationMarkers,
                      vans: _nearbyVans,
                      onVanTap: (van) {
                        _showVanBookingPreview(van);
                      },
                    ),
                  ),

                  // Bottom Sliding Available Vans Card
                  Positioned(
                    bottom: 16.h,
                    left: 16.w,
                    right: 16.w,
                    child: _buildBottomAvailableVansCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAvailableVansCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: const BoxDecoration(
                      color: AppColors.stitchAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'عربيات سوزوكي جاهزة للتحميل',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.stitchCobaltLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'خط الحصري - جهينة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.stitchCobalt,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Featured van item
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColors.stitchCobaltLight,
                  child: const Icon(Icons.person, color: AppColors.stitchCobalt),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'الأسطى محمد الشناوي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          const Icon(Icons.star, color: AppColors.stitchAmber, size: 12),
                          Text(
                            '4.9',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'متبقي ٣ مقاعد • الأجرة ٧ ج.م',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: AppColors.stitchCobalt,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.pushNamed(
                      AppRoute.seatBooking.name,
                      pathParameters: {'routeId': 'route_october_101'},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.stitchCobalt,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'احجز كرسيك',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVanBookingPreview(OsmVanMarker van) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    van.driverName,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const EgyptianLicensePlate(),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'المقاعد الشاغرة: ${van.availableSeats} من ٧ كراسي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  color: AppColors.stitchCobalt,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    AppRoute.seatBooking.name,
                    pathParameters: {'routeId': van.id},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.stitchCobalt,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'اختيار هذه السيارة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
