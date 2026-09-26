import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_colors.dart';

class OsmStationMarker {
  const OsmStationMarker({
    required this.id,
    required this.title,
    required this.point,
    this.isHub = false,
  });

  final String id;
  final String title;
  final LatLng point;
  final bool isHub;
}

class OsmVanMarker {
  const OsmVanMarker({
    required this.id,
    required this.driverName,
    required this.availableSeats,
    required this.point,
  });

  final String id;
  final String driverName;
  final int availableSeats;
  final LatLng point;
}

class OsmMapWidget extends StatelessWidget {
  const OsmMapWidget({
    super.key,
    required this.initialCenter,
    this.initialZoom = 13.5,
    this.stations = const [],
    this.vans = const [],
    this.routePoints = const [],
    this.onStationTap,
    this.onVanTap,
    this.height,
  });

  final LatLng initialCenter;
  final double initialZoom;
  final List<OsmStationMarker> stations;
  final List<OsmVanMarker> vans;
  final List<LatLng> routePoints;
  final ValueChanged<OsmStationMarker>? onStationTap;
  final ValueChanged<OsmVanMarker>? onVanTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.suzuki.app',
                ),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.5,
                        color: AppColors.stitchCobalt.withOpacity(0.8),
                        borderStrokeWidth: 1.5,
                        borderColor: Colors.white,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // Station markers
                    ...stations.map((s) => Marker(
                          point: s.point,
                          width: 120,
                          height: 48,
                          child: GestureDetector(
                            onTap: () => onStationTap?.call(s),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: s.isHub ? AppColors.stitchCobalt : AppColors.stitchTeal,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        s.isHub ? Icons.hub : Icons.pin_drop,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          s.title,
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 6,
                                  color: s.isHub ? AppColors.stitchCobalt : AppColors.stitchTeal,
                                ),
                              ],
                            ),
                          ),
                        )),

                    // Van markers
                    ...vans.map((v) => Marker(
                          point: v.point,
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () => onVanTap?.call(v),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.stitchCobalt,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.stitchCobalt.withOpacity(0.35),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.airport_shuttle,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: AppColors.stitchAmber,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${v.availableSeats}',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),

            // Top gradient overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
