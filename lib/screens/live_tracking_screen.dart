import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/chat_repository.dart';
import '../services/ride_repository.dart';
import '../services/user_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_avatar.dart';
import '../widgets/route_map.dart';
import 'chat_screen.dart';

class LiveTrackingScreen extends StatelessWidget {
  final String rideId;
  const LiveTrackingScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Ride?>(
        stream: RideRepository.watchOne(rideId),
        builder: (context, snapshot) {
          final ride = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ride == null) {
            return Center(child: Text('Ce trajet n\'existe plus.', style: TextStyle(color: AppColors.muted(context))));
          }
          return _TrackingBody(ride: ride);
        },
      ),
    );
  }
}

class _TrackingBody extends StatefulWidget {
  final Ride ride;
  const _TrackingBody({required this.ride});

  @override
  State<_TrackingBody> createState() => _TrackingBodyState();
}

class _TrackingBodyState extends State<_TrackingBody> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Simulated GPS: recompute the car's position every second from the
    // real clock against the ride's scheduled departure/duration, so the
    // marker actually moves along the route instead of sitting still.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Ride get ride => widget.ride;

  double get _progress {
    final now = DateTime.now();
    if (now.isBefore(ride.departure)) return 0;
    final totalSeconds = ride.duration.inSeconds;
    if (totalSeconds <= 0) return 1;
    final elapsedSeconds = now.difference(ride.departure).inSeconds;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  bool get _hasDeparted => !DateTime.now().isBefore(ride.departure);
  bool get _hasArrived => _progress >= 1.0;

  Future<void> _call(BuildContext context) async {
    final snap = await FirebaseFirestore.instance.collection('users').doc(ride.driverUid).get();
    final phone = snap.data()?['phone'] as String?;
    if (!context.mounted) return;
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ride.driverName} n\'a pas renseigné de numéro')),
      );
      return;
    }
    await launchUrl(Uri(scheme: 'tel', path: phone.trim()));
  }

  Future<void> _openChat(BuildContext context) async {
    final me = await UserRepository.fetchProfile();
    final conversationId = await ChatRepository.ensureConversation(
      otherUid: ride.driverUid,
      otherName: ride.driverName,
      myName: me.displayName,
    );
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(conversationId: conversationId, contactName: ride.driverName, otherUid: ride.driverUid),
      ),
    );
  }

  void _share() {
    Share.share(
      'Je suis en route : ${ride.from} → ${ride.to} avec ${ride.driverName}, départ prévu à '
      '${ride.departure.hour.toString().padLeft(2, '0')}:${ride.departure.minute.toString().padLeft(2, '0')}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    final progress = _progress;

    final String statusLabel;
    final Color statusColor;
    if (_hasArrived) {
      statusLabel = 'Arrivé à destination';
      statusColor = AppColors.primary;
    } else if (_hasDeparted) {
      statusLabel = 'En route';
      statusColor = AppColors.primary;
    } else {
      statusLabel = 'En attente du départ';
      statusColor = muted;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: RouteMap(
            origin: ride.fromLatLng,
            destination: ride.toLatLng,
            interactive: true,
            showCar: true,
            routeProgress: progress,
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
                _RoundButton(icon: Icons.share_outlined, onTap: _share),
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
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(statusLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: statusColor)),
                      const Spacer(),
                      Text(
                        _hasArrived ? 'Trajet terminé' : '${(progress * 100).round()} %',
                        style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: muted.withValues(alpha: 0.18),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      DriverAvatar(name: ride.driverName, size: 50),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ride.driverName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(ride.driverCar.isEmpty ? 'Véhicule non renseigné' : ride.driverCar, style: TextStyle(fontSize: 12, color: muted)),
                          ],
                        ),
                      ),
                      _CircleAction(icon: Icons.call, onTap: () => _call(context)),
                      const SizedBox(width: 8),
                      _CircleAction(icon: Icons.chat_bubble, onTap: () => _openChat(context)),
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
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 17),
      ),
    );
  }
}
