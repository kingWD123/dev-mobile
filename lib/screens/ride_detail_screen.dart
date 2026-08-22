import 'package:flutter/material.dart';
import '../services/booking_repository.dart';
import '../services/chat_repository.dart';
import '../services/ride_repository.dart';
import '../services/user_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_avatar.dart';
import '../widgets/route_map.dart';
import 'chat_screen.dart';

class RideDetailScreen extends StatelessWidget {
  final String rideId;
  const RideDetailScreen({super.key, required this.rideId});

  String _time(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail du trajet')),
      body: StreamBuilder<Ride?>(
        stream: RideRepository.watchOne(rideId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final ride = snapshot.data;
          if (ride == null) {
            return Center(
              child: Text('Ce trajet n\'existe plus.', style: TextStyle(color: AppColors.muted(context))),
            );
          }
          return _RideDetailBody(ride: ride, timeFormatter: _time);
        },
      ),
    );
  }
}

class _RideDetailBody extends StatelessWidget {
  final Ride ride;
  final String Function(DateTime) timeFormatter;
  const _RideDetailBody({required this.ride, required this.timeFormatter});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
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
                          Text(timeFormatter(ride.departure), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          const SizedBox(height: 2),
                          Text(ride.from, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                          const SizedBox(height: 30),
                          Text(timeFormatter(ride.departure.add(ride.duration)), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: muted)),
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
                  Expanded(child: _InfoTile(icon: Icons.event_seat_outlined, label: 'Places', value: ride.seats > 0 ? '${ride.seats} dispo.' : 'Complet')),
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
                    DriverAvatar(name: ride.driverName, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ride.driverName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 3),
                          Text(
                            ride.driverCar.isEmpty ? 'Véhicule non renseigné' : ride.driverCar,
                            style: TextStyle(fontSize: 12, color: muted),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        final me = await UserRepository.fetchProfile();
                        final conversationId = await ChatRepository.ensureConversation(
                          otherUid: ride.driverUid,
                          otherName: ride.driverName,
                          myName: me.displayName,
                        );
                        if (!context.mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              conversationId: conversationId,
                              contactName: ride.driverName,
                              otherUid: ride.driverUid,
                            ),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
                      ),
                    ),
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
        ),
        SafeArea(
          top: false,
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
                    onPressed: ride.seats <= 0
                        ? null
                        : () async {
                            final booked = await BookingRepository.book(ride);
                            if (!context.mounted) return;
                            if (!booked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Plus de place disponible sur ce trajet')),
                              );
                              return;
                            }
                            showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              builder: (_) => _BookingConfirmSheet(ride: ride),
                            );
                          },
                    child: Text(ride.seats <= 0 ? 'Complet' : 'Réserver'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
          const Text('Réservation confirmée', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            '${ride.driverName} a été prévenu pour votre trajet ${ride.from} → ${ride.to}.',
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
