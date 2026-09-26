import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

enum RideMode { shared, charter }

class SeatCounterSelector extends StatelessWidget {
  const SeatCounterSelector({
    super.key,
    required this.seatCount,
    required this.maxSeats,
    required this.pricePerSeat,
    required this.charterPrice,
    required this.selectedMode,
    required this.onCountChanged,
    required this.onModeChanged,
  });

  final int seatCount;
  final int maxSeats;
  final int pricePerSeat;
  final int charterPrice;
  final RideMode selectedMode;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<RideMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final totalPrice = selectedMode == RideMode.charter ? charterPrice : (seatCount * pricePerSeat);

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عايز كام كرسي؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'احجز مقاعد ليك أو للمرافقين معاك',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 40.r,
                height: 40.r,
                decoration: const BoxDecoration(
                  color: AppColors.stitchCobaltLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.airline_seat_recline_normal,
                  color: AppColors.stitchCobalt,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Counter Stepper Controller
          if (selectedMode == RideMode.shared) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Decrement Button
                  IconButton(
                    onPressed: seatCount > 1 ? () => onCountChanged(seatCount - 1) : null,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.onSurface,
                      elevation: 1,
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(Icons.remove),
                  ),

                  // Display
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$seatCount',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.stitchCobalt,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            seatCount == 1 ? 'كرسي' : 'كراسي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'الأجرة $pricePerSeat ج.م للكرسي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),

                  // Increment Button
                  IconButton(
                    onPressed: seatCount < maxSeats ? () => onCountChanged(seatCount + 1) : null,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.stitchCobalt,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Capacity Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
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
                      Flexible(
                        child: Text(
                          'المتاح: $maxSeats مقاعد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'سعة العربية ٧ ركاب',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: (7 - maxSeats) / 7.0,
                backgroundColor: AppColors.grey200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.stitchAmber),
                minHeight: 6.h,
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Ride Mode Selection (Shared vs Charter)
          Text(
            'نوع الحجز والمشوار',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildModeCard(
                  title: 'كرسي (مشترك)',
                  price: '${seatCount * pricePerSeat} ج.م',
                  isSelected: selectedMode == RideMode.shared,
                  onTap: () => onModeChanged(RideMode.shared),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildModeCard(
                  title: 'العربية كلها (مخصوص)',
                  price: '$charterPrice ج.م',
                  isSelected: selectedMode == RideMode.charter,
                  onTap: () => onModeChanged(RideMode.charter),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Total Fare Summary
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.stitchCobaltLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'الإجمالي المطلوب للدفع كاش:',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.stitchCobalt,
                    ),
                  ),
                ),
                Text(
                  '$totalPrice ج.م',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.stitchCobalt,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.stitchCobalt : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.stitchCobalt : AppColors.grey200,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              price,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                color: isSelected ? AppColors.stitchAmberLight : AppColors.stitchCobalt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
