import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/cash_handover_card.dart';
import '../../../../core/widgets/driver_badge_card.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../../core/widgets/seat_counter_selector.dart';
import '../../../../core/widgets/suzuki_cabin_grid.dart';

class SeatBookingScreen extends StatefulWidget {
  const SeatBookingScreen({super.key, required this.routeId});

  final String routeId;

  @override
  State<SeatBookingScreen> createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends State<SeatBookingScreen> {
  int _selectedSeatCount = 1;
  RideMode _selectedMode = RideMode.shared;
  bool _isSubmitting = false;

  // Seat cabin map state (1 to 7)
  // Seats 2, 3 are occupied by previous riders
  final Map<int, SeatStatus> _seatMap = {
    1: SeatStatus.available,
    2: SeatStatus.occupied,
    3: SeatStatus.occupied,
    4: SeatStatus.available,
    5: SeatStatus.available,
    6: SeatStatus.available,
    7: SeatStatus.available,
  };

  @override
  void initState() {
    super.initState();
    _syncSeatSelection();
  }

  void _syncSeatSelection() {
    // Select first N available seats according to count
    int assigned = 0;
    for (int seat = 1; seat <= 7; seat++) {
      if (_seatMap[seat] == SeatStatus.occupied) continue;
      if (assigned < _selectedSeatCount) {
        _seatMap[seat] = SeatStatus.selected;
        assigned++;
      } else {
        _seatMap[seat] = SeatStatus.available;
      }
    }
  }

  void _onSeatTapped(int seatNumber) {
    setState(() {
      if (_seatMap[seatNumber] == SeatStatus.selected) {
        _seatMap[seatNumber] = SeatStatus.available;
        _selectedSeatCount = _seatMap.values.where((s) => s == SeatStatus.selected).length;
        if (_selectedSeatCount == 0) _selectedSeatCount = 1;
      } else if (_seatMap[seatNumber] == SeatStatus.available) {
        _seatMap[seatNumber] = SeatStatus.selected;
        _selectedSeatCount = _seatMap.values.where((s) => s == SeatStatus.selected).length;
      }
    });
  }

  void _onSeatCountChanged(int count) {
    setState(() {
      _selectedSeatCount = count;
      _syncSeatSelection();
    });
  }

  Future<void> _handleConfirmBooking() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Show booking snackbar & navigate to tracking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تأكيد حجزك مع الأسطى محمد بنجاح!',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
        ),
        backgroundColor: AppColors.success,
      ),
    );

    context.pushNamed(
      AppRoute.activeTracking.name,
      pathParameters: {'bookingId': 'booking_october_778'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حجز الكراسي والرحلة'),
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
            // Driver & Vehicle Badge Card
            const DriverBadgeCard(),
            SizedBox(height: 14.h),

            // Stepper and Mode Selector
            SeatCounterSelector(
              seatCount: _selectedSeatCount,
              maxSeats: 5, // 2 already occupied out of 7
              pricePerSeat: 7,
              charterPrice: 60,
              selectedMode: _selectedMode,
              onCountChanged: _onSeatCountChanged,
              onModeChanged: (mode) {
                setState(() => _selectedMode = mode);
              },
            ),
            SizedBox(height: 14.h),

            // Interactive Suzuki Cabin Grid
            SuzukiCabinGrid(
              seatStatuses: _seatMap,
              onSeatTapped: _onSeatTapped,
            ),
            SizedBox(height: 14.h),

            // Cash Handover Assurance Note
            const CashHandoverCard(),
            SizedBox(height: 24.h),

            // Submit Button
            PrimaryActionButton(
              title: _selectedMode == RideMode.charter
                  ? 'تأكيد حجز العربية مخصوص (٦٠ ج.م)'
                  : 'تأكيد حجز ($_selectedSeatCount) مقاعد كاش',
              isLoading: _isSubmitting,
              icon: Icons.check_circle_outline,
              onPressed: _handleConfirmBooking,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
