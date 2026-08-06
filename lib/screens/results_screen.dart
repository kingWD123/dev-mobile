import 'package:flutter/material.dart';
import '../models/ride_models.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_avatar.dart';
import 'ride_detail_screen.dart';

class ResultsScreen extends StatelessWidget {
  final String from;
  final String to;
  final DateTime date;

  const ResultsScreen({super.key, required this.from, required this.to, required this.date});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    final rides = mockRides;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$from → $to', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
            Text('${rides.length} trajets disponibles', style: TextStyle(fontSize: 11.5, color: muted, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _FilterChip(label: 'Heure de départ', icon: Icons.access_time),
                  SizedBox(width: 8),
                  _FilterChip(label: 'Prix', icon: Icons.sell_outlined),
                  SizedBox(width: 8),
                  _FilterChip(label: 'Réservation instantanée', icon: Icons.flash_on_outlined),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: rides.length,
              itemBuilder: (context, i) => _RideCard(ride: rides[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FilterChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: AppColors.flatField(context, radius: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.muted(context)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final Ride ride;
  const _RideCard({required this.ride});

  String _time(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _duration(Duration d) => '${d.inHours}h${d.inMinutes.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    final arrival = ride.departure.add(ride.duration);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => RideDetailScreen(ride: ride)));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: AppColors.card(context, radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_time(ride.departure), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Divider(height: 1, color: Theme.of(context).dividerColor)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(_duration(ride.duration), style: TextStyle(fontSize: 11, color: muted)),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(_time(arrival), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(ride.from, style: TextStyle(fontSize: 12, color: muted), overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: Text(ride.to, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: muted), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            const SizedBox(height: 12),
            Row(
              children: [
                DriverAvatar(driver: ride.driver, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.driver.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: AppColors.rating),
                          const SizedBox(width: 3),
                          Text('${ride.driver.rating}', style: TextStyle(fontSize: 11.5, color: muted)),
                          const SizedBox(width: 8),
                          Icon(Icons.event_seat_outlined, size: 12, color: muted),
                          const SizedBox(width: 3),
                          Text('${ride.seatsLeft} place${ride.seatsLeft > 1 ? 's' : ''}', style: TextStyle(fontSize: 11.5, color: muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (ride.instantBooking)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.flash_on, size: 16, color: AppColors.primary),
                  ),
                Text(
                  '${ride.price.toInt()} F',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
