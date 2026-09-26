import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/egyptian_license_plate.dart';
import '../../../../core/widgets/suzuki_cabin_grid.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = true;
  int _availableSeatsCount = 4;
  final int _farePerSeat = 7;

  // 7-passenger van seat map
  final Map<int, SeatStatus> _driverSeatMap = {
    1: SeatStatus.occupied,
    2: SeatStatus.available,
    3: SeatStatus.occupied,
    4: SeatStatus.available,
    5: SeatStatus.available,
    6: SeatStatus.occupied,
    7: SeatStatus.available,
  };

  int get _occupiedSeatsCount =>
      _driverSeatMap.values.where((s) => s == SeatStatus.occupied).length;

  int get _collectedFare => _occupiedSeatsCount * _farePerSeat;

  void _toggleSeat(int seatNumber) {
    setState(() {
      final current = _driverSeatMap[seatNumber];
      if (current == SeatStatus.occupied) {
        _driverSeatMap[seatNumber] = SeatStatus.available;
      } else {
        _driverSeatMap[seatNumber] = SeatStatus.occupied;
      }
      _availableSeatsCount =
          _driverSeatMap.values.where((s) => s == SeatStatus.available).length;
    });
  }

  void _quickAdjustAvailable(int delta) {
    setState(() {
      final newCount = (_availableSeatsCount + delta).clamp(0, 7);
      _availableSeatsCount = newCount;

      // Sync with seat map
      int toMarkOccupied = 7 - _availableSeatsCount;
      for (int i = 1; i <= 7; i++) {
        if (toMarkOccupied > 0) {
          _driverSeatMap[i] = SeatStatus.occupied;
          toMarkOccupied--;
        } else {
          _driverSeatMap[i] = SeatStatus.available;
        }
      }
    });
  }

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
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => context.pushNamed(AppRoute.driverEarnings.name),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Online / Offline Status Banner ───────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _isOnline ? AppColors.stitchTealLight : AppColors.grey200,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _isOnline ? AppColors.stitchTeal : AppColors.grey400,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: _isOnline ? AppColors.stitchTeal : AppColors.grey600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOnline ? 'أنت الآن متصل • جاهز للتحميل' : 'أنت الآن غير متصل',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: _isOnline ? AppColors.stitchTeal : AppColors.grey800,
                            ),
                          ),
                          Text(
                            'خط سير: موقف الحصري ➔ ميدان جهينة',
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
                  Switch.adaptive(
                    value: _isOnline,
                    activeColor: AppColors.stitchTeal,
                    onChanged: (val) {
                      setState(() => _isOnline = val);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // ── License Plate & Driver Identity ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const EgyptianLicensePlate(
                  numbers: '٥ ٤ ٨ ٢',
                  letters: 'ق ن ص',
                ),
                Text(
                  'الأسطى محمد الشناوي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // ── Live Trip Summary ────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(14.r),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'عدد الركاب الحاليين',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_occupiedSeatsCount',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.stitchCobalt,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '/ ٧ كراسي',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40.h, color: AppColors.grey200),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الأجرة المحصلة نقداً',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_collectedFare',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.stitchAmber,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'ج.م',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onAmber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // ── Fast Road Stepper (+ / -) ─────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تعديل سريع للمقاعد الشاغرة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'تحديث فوري لركاب المحطة أثناء الطريق',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _quickAdjustAvailable(-1),
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.grey200,
                          foregroundColor: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '$_availableSeatsCount',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.stitchCobalt,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed: () => _quickAdjustAvailable(1),
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.stitchCobalt,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // ── Interactive Cabin Grid for Driver ────────────────────────────
            Text(
              'انقر على المقعد لتحديده كـ شاغر أو مشغول:',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
            SizedBox(height: 6.h),
            SuzukiCabinGrid(
              seatStatuses: _driverSeatMap,
              isDriverView: true,
              onSeatTapped: _toggleSeat,
            ),
            SizedBox(height: 16.h),

            // ── Incoming Passenger Booking Request Alert ─────────────────────
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.stitchAmberLight.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.stitchAmber, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_pin, color: AppColors.stitchAmber, size: 20.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'طلب حجز جديد في انتظارك!',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onAmber,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'منذ دقيقة',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 10.sp, color: AppColors.grey600),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'الراكب: أحمد فتحي • مقعدان (١٤ ج.م كاش)',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppColors.onSurface),
                  ),
                  Text(
                    'نقطة الركوب: موقف الحصري (أمام بنك مصر)',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: AppColors.grey600),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم قبول طلب الحجز وتأكيد المقاعد'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.stitchCobalt,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: const Text('قبول الطلب'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: const Text('اعتذار'),
                        ),
                      ),
                    ],
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
