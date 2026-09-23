import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/screen_util_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../cubit/passenger_cubits.dart';
import '../cubit/passenger_states.dart';

/// Real-time driver tracking screen shown after seat booking.
class ActiveTrackingScreen extends StatefulWidget {
  const ActiveTrackingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ActiveTrackingScreen> createState() => _ActiveTrackingScreenState();
}

class _ActiveTrackingScreenState extends State<ActiveTrackingScreen> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().loadActiveBooking();
  }

  void _onCancelBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء الحجز'),
        content: const Text('هل أنت متأكد من إلغاء هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<BookingCubit>()
                  .cancelBooking(bookingId: bookingId);
            },
            child: Text(AppStrings.confirm,
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.activeTrip),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: LoadingIndicator());
          }
          if (state is ActiveBookingLoaded && state.booking != null) {
            final booking = state.booking!;
            final driverLoc = booking.currentDriverLocation ??
                const LatLng(24.7136, 46.6753);
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: driverLoc,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'sa.suzuki_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: driverLoc,
                          width: 48.w,
                          height: 48.w,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.markerSuzuki,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 3),
                            ),
                            child: Icon(Icons.directions_car_rounded,
                                color: Colors.white, size: 22.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _TrackingInfoCard(
                    booking: booking,
                    onCancel: () => _onCancelBooking(booking.bookingId),
                  ),
                ),
              ],
            );
          }
          if (state is BookingCancelled) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined,
                      size: 64.sp, color: AppColors.error),
                  SizedBox(height: AppSpacing.vlg),
                  Text('تم إلغاء الحجز', style: AppTextStyles.headlineSmall),
                  SizedBox(height: AppSpacing.vxl),
                  CustomButton(
                    label: 'العودة للرئيسية',
                    onPressed: () => context.go('/passenger/home'),
                    width: 200.w,
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('لا يوجد حجز نشط'));
        },
      ),
    );
  }
}

class _TrackingInfoCard extends StatelessWidget {
  const _TrackingInfoCard({required this.booking, required this.onCancel});
  final dynamic booking;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: AppSpacing.vmd),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          Row(
            children: [
              _InfoTile(
                icon: Icons.person_rounded,
                label: 'السائق',
                value: booking.driverName ?? '—',
              ),
              const SizedBox(width: 16),
              _InfoTile(
                icon: Icons.event_seat_rounded,
                label: 'المقعد',
                value: '${booking.seatNumber}',
              ),
              const SizedBox(width: 16),
              _InfoTile(
                icon: Icons.access_time_rounded,
                label: AppStrings.arrivalTime,
                value: booking.estimatedArrival != null
                    ? DateFormatter.time(booking.estimatedArrival!)
                    : '—',
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vmd),
          CustomButton(
            label: 'إلغاء الحجز',
            onPressed: onCancel,
            variant: ButtonVariant.danger,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22.sp),
          SizedBox(height: AppSpacing.vxs),
          Text(label,
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.grey600)),
          Text(value,
              style: AppTextStyles.titleSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
