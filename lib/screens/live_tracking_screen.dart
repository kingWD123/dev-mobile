import 'package:flutter/material.dart';
import '../models/ride_models.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_avatar.dart';
import '../widgets/route_map.dart';

class LiveTrackingScreen extends StatelessWidget {
  final Ride ride;
  const LiveTrackingScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RouteMap(
              origin: ride.fromLatLng,
              destination: ride.toLatLng,
              interactive: true,
              showCar: true,
              routeProgress: 0.42,
              borderRadius: BorderRadius.zero,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  _RoundButton(icon: Icons.arrow_back, onTap: () => Navigator.of(context).pop()),
                  const Spacer(),
                  _RoundButton(icon: Icons.share_outlined, onTap: () {}),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('En route', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.primary)),
                        const Spacer(),
                        Text('Arrivée estimée 18 min', style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        DriverAvatar(driver: ride.driver, size: 50),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride.driver.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(ride.driver.car, style: TextStyle(fontSize: 12, color: muted)),
                            ],
                          ),
                        ),
                        _CircleAction(icon: Icons.call, onTap: () {}),
                        const SizedBox(width: 8),
                        _CircleAction(icon: Icons.chat_bubble, onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text('${ride.from}  →  ${ride.to}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: BoxShape.circle,
          // Floating over map imagery needs real contrast, unlike the flat
          // bordered cards used elsewhere — a soft shadow instead of a hairline.
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Icon(icon, size: 19, color: AppColors.ink(context)),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.only(left: 0),
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 17),
      ),
    );
  }
}
