import 'package:flutter/material.dart';
import '../services/ride_repository.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$from → $to', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
            StreamBuilder<List<Ride>>(
              stream: RideRepository.watchAll(),
              builder: (context, snapshot) {
                final count = _filter(snapshot.data ?? const []).length;
                return Text('$count trajet${count > 1 ? 's' : ''} disponible${count > 1 ? 's' : ''}', style: TextStyle(fontSize: 11.5, color: muted, fontWeight: FontWeight.w500));
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Ride>>(
        stream: RideRepository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rides = _filter(snapshot.data ?? const []);
          if (rides.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Aucun trajet publié pour cet itinéraire pour l\'instant. Reviens plus tard ou publie le tien !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 13.5),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: rides.length,
            itemBuilder: (context, i) => _RideCard(ride: rides[i]),
          );
        },
      ),
    );
  }

  List<Ride> _filter(List<Ride> rides) {
    final f = from.trim().toLowerCase();
    final t = to.trim().toLowerCase();
    return rides.where((r) {
      final matchesFrom = f.isEmpty || r.from.toLowerCase().contains(f) || f.contains(r.from.toLowerCase());
      final matchesTo = t.isEmpty || r.to.toLowerCase().contains(t) || t.contains(r.to.toLowerCase());
      return matchesFrom && matchesTo;
    }).toList();
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
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => RideDetailScreen(rideId: ride.id)));
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
                DriverAvatar(name: ride.driverName, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.driverName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      Row(
                        children: [
                          Icon(Icons.event_seat_outlined, size: 12, color: muted),
                          const SizedBox(width: 3),
                          Text('${ride.seats} place${ride.seats > 1 ? 's' : ''}', style: TextStyle(fontSize: 11.5, color: muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (ride.instantBooking)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
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
