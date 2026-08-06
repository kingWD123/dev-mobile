import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';

class RouteMap extends StatelessWidget {
  final LatLng origin;
  final LatLng destination;
  final double height;
  final bool interactive;
  final bool showCar;
  final double routeProgress;
  final BorderRadius? borderRadius;

  const RouteMap({
    super.key,
    required this.origin,
    required this.destination,
    this.height = 180,
    this.interactive = false,
    this.showCar = false,
    this.routeProgress = 0.5,
    this.borderRadius,
  });

  LatLng get _center => LatLng(
        (origin.latitude + destination.latitude) / 2,
        (origin.longitude + destination.longitude) / 2,
      );

  double get _zoom {
    final span = math.max(
      (origin.latitude - destination.latitude).abs(),
      (origin.longitude - destination.longitude).abs(),
    );
    if (span > 4) return 6;
    if (span > 2) return 7;
    if (span > 1) return 7.6;
    if (span > 0.5) return 9;
    if (span > 0.2) return 10;
    return 11;
  }

  LatLng _pointAlongRoute(double t) => LatLng(
        origin.latitude + (destination.latitude - origin.latitude) * t,
        origin.longitude + (destination.longitude - origin.longitude) * t,
      );

  double get _bearingRadians {
    final lat1 = origin.latitude * math.pi / 180;
    final lat2 = destination.latitude * math.pi / 180;
    final dLon = (destination.longitude - origin.longitude) * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return math.atan2(y, x);
  }

  @override
  Widget build(BuildContext context) {
    final carPoint = _pointAlongRoute(routeProgress.clamp(0.0, 1.0));

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            IgnorePointer(
              ignoring: !interactive,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: _zoom,
                  interactionOptions: InteractionOptions(
                    flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.dic2.devmobile.covoiturage_app',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(points: [origin, destination], strokeWidth: 4, color: AppColors.primary),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(point: origin, width: 18, height: 18, child: const _OriginDot()),
                      Marker(
                        point: destination,
                        width: 32,
                        height: 32,
                        alignment: Alignment.topCenter,
                        child: const Icon(Icons.location_on, color: AppColors.primary, size: 30),
                      ),
                      if (showCar)
                        Marker(
                          point: carPoint,
                          width: 32,
                          height: 32,
                          child: Transform.rotate(angle: _bearingRadians, child: const _CarMarker()),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Positioned(right: 6, bottom: 6, child: _Attribution()),
          ],
        ),
      ),
    );
  }
}

class _OriginDot extends StatelessWidget {
  const _OriginDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
    );
  }
}

class _CarMarker extends StatelessWidget {
  const _CarMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      child: const Icon(Icons.navigation, color: Colors.white, size: 18),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text('© OpenStreetMap', style: TextStyle(fontSize: 8.5, color: Colors.black87)),
    );
  }
}
