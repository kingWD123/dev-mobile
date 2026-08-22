import 'package:flutter/material.dart';
import '../services/booking_repository.dart';
import '../services/ride_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/car_illustration.dart';
import 'live_tracking_screen.dart';
import 'ride_detail_screen.dart';

class _TripEntry {
  final String rideId;
  final String from;
  final String to;
  final DateTime departure;
  final double price;
  final bool asDriver;
  final String otherPartyLabel;

  const _TripEntry({
    required this.rideId,
    required this.from,
    required this.to,
    required this.departure,
    required this.price,
    required this.asDriver,
    required this.otherPartyLabel,
  });
}

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late final TabController tabController = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<List<BookedTrip>>(
        stream: BookingRepository.watchMyBookings(),
        builder: (context, bookingSnap) {
          return StreamBuilder<List<Ride>>(
            stream: RideRepository.watchMine(),
            builder: (context, rideSnap) {
              final bookings = bookingSnap.data ?? const [];
              final myRides = rideSnap.data ?? const [];

              final entries = [
                ...bookings.map((b) => _TripEntry(
                      rideId: b.rideId,
                      from: b.from,
                      to: b.to,
                      departure: b.departure,
                      price: b.price,
                      asDriver: false,
                      otherPartyLabel: 'Avec ${b.driverName}',
                    )),
                ...myRides.map((r) => _TripEntry(
                      rideId: r.id,
                      from: r.from,
                      to: r.to,
                      departure: r.departure,
                      price: r.price,
                      asDriver: true,
                      otherPartyLabel: 'Conducteur',
                    )),
              ]..sort((a, b) => b.departure.compareTo(a.departure));

              final now = DateTime.now();
              final upcoming = entries.where((e) => e.departure.isAfter(now)).toList();
              final past = entries.where((e) => !e.departure.isAfter(now)).toList();

              return TabBarView(
                controller: tabController,
                children: [
                  _TripList(entries: upcoming, emptyText: 'Aucun trajet à venir'),
                  _TripList(entries: past, emptyText: 'Aucun trajet passé'),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  final List<_TripEntry> entries;
  final String emptyText;
  const _TripList({required this.entries, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CarIllustration(width: 140, bodyColor: muted.withValues(alpha: 0.45)),
            const SizedBox(height: 16),
            Text(emptyText, style: TextStyle(color: muted, fontSize: 13.5)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: entries.length,
      itemBuilder: (context, i) => _TripCard(entry: entries[i]),
    );
  }
}

class _TripCard extends StatelessWidget {
  final _TripEntry entry;
  const _TripCard({required this.entry});

  String _date(DateTime d) {
    const months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    final upcoming = entry.departure.isAfter(DateTime.now());

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RideDetailScreen(rideId: entry.rideId))),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppColors.card(context, radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: (upcoming ? AppColors.primary : muted).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    entry.asDriver ? Icons.drive_eta_outlined : Icons.directions_car_outlined,
                    color: upcoming ? AppColors.primary : muted,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.from} → ${entry.to}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(
                        '${_date(entry.departure)} · ${entry.otherPartyLabel}',
                        style: TextStyle(fontSize: 12, color: muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${entry.price.toInt()} F', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primary)),
              ],
            ),
            if (upcoming) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LiveTrackingScreen(rideId: entry.rideId))),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.navigation_outlined, size: 16),
                  label: const Text('Suivre en direct', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
