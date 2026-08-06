import 'package:flutter/material.dart';
import '../models/ride_models.dart';
import '../theme/app_theme.dart';
import 'ride_detail_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late final TabController tabController = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    final upcoming = mockTrips.where((t) => t.status == TripStatus.upcoming).toList();
    final past = mockTrips.where((t) => t.status == TripStatus.past).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes trajets'),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.muted(context),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          tabs: const [Tab(text: 'À venir'), Tab(text: 'Passés')],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _TripList(trips: upcoming, emptyText: 'Aucun trajet à venir'),
          _TripList(trips: past, emptyText: 'Aucun trajet passé'),
        ],
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  final List<Trip> trips;
  final String emptyText;
  const _TripList({required this.trips, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    if (trips.isEmpty) {
      return Center(
        child: Text(emptyText, style: TextStyle(color: muted, fontSize: 13.5)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: trips.length,
      itemBuilder: (context, i) => _TripCard(trip: trips[i]),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  const _TripCard({required this.trip});

  String _date(DateTime d) {
    const months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    final ride = trip.ride;

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RideDetailScreen(ride: ride))),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppColors.card(context, radius: 18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: (trip.status == TripStatus.past ? muted : AppColors.primary).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                trip.asDriver ? Icons.drive_eta_outlined : Icons.directions_car_outlined,
                color: trip.status == TripStatus.past ? muted : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${ride.from} → ${ride.to}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    '${_date(ride.departure)} · ${trip.asDriver ? "Conducteur" : "Avec ${ride.driver.name}"}',
                    style: TextStyle(fontSize: 12, color: muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${ride.price.toInt()} F', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
