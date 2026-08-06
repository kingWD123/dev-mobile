import 'package:flutter/material.dart';
import '../models/ride_models.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_avatar.dart';
import '../widgets/route_map.dart';

class RideDetailScreen extends StatelessWidget {
  final Ride ride;
  const RideDetailScreen({super.key, required this.ride});

  String _time(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    final arrival = ride.departure.add(ride.duration);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du trajet')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        children: [
          RouteMap(origin: ride.fromLatLng, destination: ride.toLatLng, height: 170),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppColors.card(context, radius: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    Container(width: 1.5, height: 54, color: Theme.of(context).dividerColor),
                    const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_time(ride.departure), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 2),
                      Text(ride.from, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                      const SizedBox(height: 30),
                      Text(_time(arrival), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: muted)),
                      const SizedBox(height: 2),
                      Text(ride.to, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _InfoTile(icon: Icons.timer_outlined, label: 'Durée', value: '${ride.duration.inHours}h${ride.duration.inMinutes.remainder(60).toString().padLeft(2, '0')}')),
              const SizedBox(width: 10),
              Expanded(child: _InfoTile(icon: Icons.event_seat_outlined, label: 'Places', value: '${ride.seatsLeft} dispo.')),
              const SizedBox(width: 10),
              Expanded(child: _InfoTile(icon: Icons.flash_on_outlined, label: 'Résa.', value: ride.instantBooking ? 'Instantanée' : 'À confirmer')),
            ],
          ),
          const SizedBox(height: 24),
          Text('Conducteur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: muted)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppColors.card(context, radius: 20),
            child: Row(
              children: [
                DriverAvatar(driver: ride.driver, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.driver.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: AppColors.rating),
                          const SizedBox(width: 3),
                          Text('${ride.driver.rating} · ${ride.driver.trips} trajets', style: TextStyle(fontSize: 12, color: muted)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(ride.driver.car, style: TextStyle(fontSize: 12, color: muted)),
                    ],
                  ),
                ),
                Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Ce qui est inclus', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: muted)),
          const SizedBox(height: 10),
          const _Bullet(text: 'Prise en charge au point de départ convenu'),
          const _Bullet(text: 'Annulation gratuite jusqu\'à 1h avant le départ'),
          const _Bullet(text: '2 bagages par passager inclus'),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prix', style: TextStyle(fontSize: 11.5, color: muted)),
                  Text('${ride.price.toInt()} FCFA', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (_) => _BookingConfirmSheet(ride: ride),
                    );
                  },
                  child: const Text('Réserver'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: AppColors.flatField(context),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5), textAlign: TextAlign.center),
          Text(label, style: TextStyle(fontSize: 10.5, color: muted)),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.check_circle, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.ink(context))),
          ),
        ],
      ),
    );
  }
}

class _BookingConfirmSheet extends StatelessWidget {
  final Ride ride;
  const _BookingConfirmSheet({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          const Text('Demande de réservation envoyée', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            '${ride.driver.name} va confirmer votre place pour ${ride.from} → ${ride.to}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}
