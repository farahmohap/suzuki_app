import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/screen_util_helper.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/route_entity.dart';
import '../cubit/passenger_cubits.dart';
import '../cubit/passenger_states.dart';

/// Passenger home: full-screen OpenStreetMap + nearby Suzuki route cards.
class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final _mapController = MapController();
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _determineLocation();
    if (_userLocation != null) {
      context.read<BookingCubit>().loadRoutes(
            latitude: _userLocation!.latitude,
            longitude: _userLocation!.longitude,
          );
    }
  }

  Future<void> _determineLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_userLocation!, 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen map ─────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _userLocation ?? const LatLng(24.7136, 46.6753), // Riyadh
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'sa.suzuki_app',
              ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 40.w,
                      height: 40.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
                  if (state is! RoutesLoaded) return const SizedBox();
                  return MarkerLayer(
                    markers: state.routes
                        .map(
                          (r) => Marker(
                            point: r.origin,
                            width: 48.w,
                            height: 48.w,
                            child: _SuzukiMarker(route: r),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),

          // ── Top search bar ──────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: _SearchBar(
              onLocationTap: _determineLocation,
            ),
          ),

          // ── Bottom sheet: route cards ───────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _RouteBottomSheet(
              onRouteSelected: (route) {
                context.pushNamed(
                  AppRoute.seatBooking.name,
                  pathParameters: {'routeId': route.routeId},
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _determineLocation,
        mini: true,
        child: const Icon(Icons.my_location_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onLocationTap});
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.grey600),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.search,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey400),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.gps_fixed_rounded, color: AppColors.primary),
            onPressed: onLocationTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _RouteBottomSheet extends StatelessWidget {
  const _RouteBottomSheet({required this.onRouteSelected});
  final void Function(RouteEntity) onRouteSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 280.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
              color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: AppSpacing.sm),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Text(AppStrings.nearbyRoutes, style: AppTextStyles.titleMedium),
                const Spacer(),
                BlocBuilder<BookingCubit, BookingState>(
                  builder: (context, state) {
                    if (state is! RoutesLoaded) return const SizedBox();
                    return Text(
                      '${state.routes.length} مسار',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey600),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<BookingCubit, BookingState>(
              builder: (context, state) {
                if (state is BookingLoading) {
                  return const Center(child: LoadingIndicator());
                }
                if (state is BookingError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () => context.read<BookingCubit>().loadRoutes(
                          latitude: 24.7136,
                          longitude: 46.6753,
                        ),
                  );
                }
                if (state is RoutesLoaded) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    itemCount: state.routes.length,
                    itemBuilder: (_, i) => _RouteCard(
                      route: state.routes[i],
                      onTap: () => onRouteSelected(state.routes[i]),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route, required this.onTap});
  final RouteEntity route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200.w,
        margin: EdgeInsets.only(left: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 6)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car_rounded,
                    color: AppColors.primary, size: 18.sp),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    route.name,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.vsm),
            Text(
              '${route.originName} ← ${route.destinationName}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.vsm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Badge(
                  label: '${route.availableSeats} مقعد',
                  color: route.hasAvailableSeats
                      ? AppColors.success
                      : AppColors.error,
                ),
                Text(
                  '${route.fare.toStringAsFixed(0)} ر.س',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuzukiMarker extends StatelessWidget {
  const _SuzukiMarker({required this.route});
  final RouteEntity route;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.markerSuzuki,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(Icons.directions_car, color: Colors.white, size: 20.sp),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style:
            AppTextStyles.labelSmall.copyWith(color: color, fontSize: 10.sp),
      ),
    );
  }
}
