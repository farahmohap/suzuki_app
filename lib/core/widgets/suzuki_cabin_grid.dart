import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

enum SeatStatus {
  available,
  selected,
  occupied,
  cashLocked,
}

/// Interactive 7-passenger cabin seat map modeled directly after Egyptian Suzuki minivans.
/// Front Row: Driver icon + Front Passenger Seat
/// Middle Row: 3 Seats (Middle Bench - الكنبة الوسطانية)
/// Back Row: 3 Seats (Back Bench - الكنبة الأخيرة)
class SuzukiCabinGrid extends StatelessWidget {
  const SuzukiCabinGrid({
    super.key,
    required this.seatStatuses,
    required this.onSeatTapped,
    this.isDriverView = false,
  });

  /// Map of seat number (1-7) to its current [SeatStatus]
  final Map<int, SeatStatus> seatStatuses;
  final ValueChanged<int> onSeatTapped;
  final bool isDriverView;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey200, width: 1.5),
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
          // Cabin Header & Legend
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              Text(
                'مخطط كبينة السوزوكي (٧ راكب)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              _buildLegend(),
            ],
          ),
          SizedBox(height: 16.h),

          // Cabin Frame
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                // Front Windshield indicator
                Container(
                  width: 80.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey400,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 14.h),

                // ── ROW 1: Driver + Front Passenger (Seat 1) ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Driver Seat (Fixed)
                    _buildDriverSeat(),
                    // Front passenger seat (Seat 1)
                    _buildSeatItem(1, 'جنب السواق'),
                  ],
                ),
                SizedBox(height: 14.h),

                // ── ROW 2: Middle Bench (Seats 2, 3, 4) ──────────────────────
                _buildRowLabel('الكنبة الوسطانية'),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSeatItem(2, 'يمين'),
                    _buildSeatItem(3, 'وسط'),
                    _buildSeatItem(4, 'شباك'),
                  ],
                ),
                SizedBox(height: 14.h),

                // ── ROW 3: Back Bench (Seats 5, 6, 7) ────────────────────────
                _buildRowLabel('الكنبة الأخيرة'),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSeatItem(5, 'يمين'),
                    _buildSeatItem(6, 'وسط'),
                    _buildSeatItem(7, 'شباك'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowLabel(String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11.sp,
          color: AppColors.grey600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDriverSeat() {
    return Container(
      width: 70.r,
      height: 70.r,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey400),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airline_seat_recline_normal, color: AppColors.grey600, size: 24.sp),
          SizedBox(height: 2.h),
          Text(
            'الكابتن',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatItem(int seatNumber, String label) {
    final status = seatStatuses[seatNumber] ?? SeatStatus.available;
    final isSelected = status == SeatStatus.selected;
    final isOccupied = status == SeatStatus.occupied;

    Color bg;
    Color border;
    Color text;
    IconData icon;

    switch (status) {
      case SeatStatus.selected:
        bg = AppColors.stitchCobalt;
        border = AppColors.stitchCobalt;
        text = Colors.white;
        icon = Icons.check_circle;
      case SeatStatus.occupied:
        bg = AppColors.grey200;
        border = AppColors.grey400;
        text = AppColors.grey600;
        icon = Icons.person;
      case SeatStatus.cashLocked:
        bg = AppColors.stitchAmberLight;
        border = AppColors.stitchAmber;
        text = AppColors.onAmber;
        icon = Icons.payments;
      case SeatStatus.available:
        bg = Colors.white;
        border = AppColors.primary;
        text = AppColors.primary;
        icon = Icons.airline_seat_recline_normal;
    }

    return GestureDetector(
      onTap: () {
        if (!isOccupied || isDriverView) {
          onSeatTapped(seatNumber);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70.r,
        height: 70.r,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: border, width: isSelected ? 2 : 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.stitchCobalt.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: text, size: 22.sp),
            SizedBox(height: 2.h),
            Text(
              'مقعد $seatNumber',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem(AppColors.primary, 'شاغر'),
        SizedBox(width: 8.w),
        _buildLegendItem(AppColors.stitchCobalt, 'محدد'),
        SizedBox(width: 8.w),
        _buildLegendItem(AppColors.grey400, 'محجوز'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10.sp,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }
}
