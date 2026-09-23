import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/screen_util_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../cubit/passenger_cubits.dart';
import '../cubit/passenger_states.dart';

/// Visual seat grid for a 14-seat Suzuki vehicle.
class SeatBookingScreen extends StatefulWidget {
  const SeatBookingScreen({super.key, required this.routeId});

  final String routeId;

  @override
  State<SeatBookingScreen> createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends State<SeatBookingScreen> {
  int? _selectedSeat;

  // Seats 1-14; seat 1 = driver (always occupied)
  static const int _totalSeats = 14;
  final Set<int> _occupiedSeats = {1, 4, 7}; // mock — replace with API data

  void _onSeatTap(int seat) {
    if (_occupiedSeats.contains(seat) || seat == 1) return;
    setState(() => _selectedSeat = seat == _selectedSeat ? null : seat);
  }

  void _onConfirmBooking() {
    if (_selectedSeat == null) return;
    context.read<BookingCubit>().bookSeat(
          routeId: widget.routeId,
          seatNumber: _selectedSeat!,
        );
  }

  void _onBookingState(BuildContext context, BookingState state) {
    if (state is SeatBooked) {
      context.pushReplacementNamed(
        AppRoute.activeTracking.name,
        pathParameters: {'bookingId': state.booking.bookingId},
      );
    } else if (state is BookingError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: _onBookingState,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.bookSeat),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            final isLoading = state is BookingLoading;
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _buildLegend(),
                      SizedBox(height: AppSpacing.vxl),
                      Expanded(child: _buildSeatGrid()),
                      SizedBox(height: AppSpacing.vmd),
                      _buildFooter(isLoading),
                    ],
                  ),
                ),
                if (isLoading)
                  Positioned.fill(child: LoadingIndicator.overlay()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: AppColors.grey200, label: 'محجوز'),
        SizedBox(width: AppSpacing.lg),
        _LegendItem(color: AppColors.surface, label: 'متاح'),
        SizedBox(width: AppSpacing.lg),
        _LegendItem(color: AppColors.primary, label: 'مختار'),
      ],
    );
  }

  Widget _buildSeatGrid() {
    // Suzuki layout: 1 driver row + 3 passenger rows of 4 + 1 row of 2
    return Column(
      children: [
        _buildVehicleOutline(),
      ],
    );
  }

  Widget _buildVehicleOutline() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.grey200, width: 2),
      ),
      child: Column(
        children: [
          // Driver row
          Row(
            children: [
              _SeatWidget(
                seatNumber: 1,
                isDriver: true,
                isOccupied: true,
                isSelected: false,
                onTap: () {},
              ),
              const Spacer(),
              Icon(Icons.airline_seat_recline_extra,
                  color: AppColors.grey400, size: 28.sp),
            ],
          ),
          SizedBox(height: AppSpacing.vmd),
          // Passenger rows: seats 2–14
          for (int row = 0; row < 3; row++)
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.vsm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int col = 0; col < 4; col++)
                    Builder(builder: (_) {
                      final seat = 2 + (row * 4) + col;
                      if (seat > _totalSeats) return SizedBox(width: 56.w);
                      return _SeatWidget(
                        seatNumber: seat,
                        isDriver: false,
                        isOccupied: _occupiedSeats.contains(seat),
                        isSelected: _selectedSeat == seat,
                        onTap: () => _onSeatTap(seat),
                      );
                    }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isLoading) {
    return Column(
      children: [
        if (_selectedSeat != null)
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            margin: EdgeInsets.only(bottom: AppSpacing.vmd),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المقعد المختار: $_selectedSeat',
                  style: AppTextStyles.titleSmall,
                ),
                Icon(Icons.event_seat_rounded,
                    color: AppColors.primary, size: 20.sp),
              ],
            ),
          ),
        CustomButton(
          label: AppStrings.confirmBooking,
          onPressed: _selectedSeat == null || isLoading
              ? null
              : _onConfirmBooking,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _SeatWidget extends StatelessWidget {
  const _SeatWidget({
    required this.seatNumber,
    required this.isDriver,
    required this.isOccupied,
    required this.isSelected,
    required this.onTap,
  });

  final int seatNumber;
  final bool isDriver;
  final bool isOccupied;
  final bool isSelected;
  final VoidCallback onTap;

  Color get _bgColor {
    if (isDriver || isOccupied) return AppColors.grey200;
    if (isSelected) return AppColors.primary;
    return AppColors.surface;
  }

  Color get _iconColor {
    if (isSelected) return AppColors.onPrimary;
    if (isDriver || isOccupied) return AppColors.grey600;
    return AppColors.grey400;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isDriver || isOccupied) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDriver
                  ? Icons.person_rounded
                  : Icons.airline_seat_recline_normal_rounded,
              color: _iconColor,
              size: 22.sp,
            ),
            Text(
              '$seatNumber',
              style: AppTextStyles.labelSmall.copyWith(color: _iconColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: AppColors.grey200),
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
