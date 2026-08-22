import 'package:flutter/material.dart';
import '../data/senegal_regions.dart';
import '../services/ride_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/promo_banner.dart';
import '../widgets/region_picker_sheet.dart';
import 'notifications_screen.dart';
import 'results_screen.dart';
import 'ride_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SenegalRegion fromRegion = SenegalRegions.all[0];
  SenegalRegion toRegion = SenegalRegions.all[1];
  DateTime selectedDate = DateTime.now();
  int passengers = 1;

  void _swap() {
    setState(() {
      final tmp = fromRegion;
      fromRegion = toRegion;
      toRegion = tmp;
    });
  }

  Future<void> _pickFrom() async {
    final picked = await pickSenegalRegion(context, title: 'Départ', current: fromRegion, disallow: toRegion);
    if (picked != null) setState(() => fromRegion = picked);
  }

  Future<void> _pickTo() async {
    final picked = await pickSenegalRegion(context, title: 'Arrivée', current: toRegion, disallow: fromRegion);
    if (picked != null) setState(() => toRegion = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  String _formatDate(DateTime d) {
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    final today = DateTime.now();
    if (d.year == today.year && d.month == today.month && d.day == today.day) {
      return "Aujourd'hui";
    }
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Covoiturage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 23),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text(
            'Où allez-vous ?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.15,
              color: AppColors.ink(context),
            ),
          ),
          const SizedBox(height: 6),
          Text('Trouvez un trajet partagé en quelques secondes', style: TextStyle(fontSize: 13.5, color: muted)),
          const SizedBox(height: 24),
          _RouteCard(
            fromRegion: fromRegion,
            toRegion: toRegion,
            onTapFrom: _pickFrom,
            onTapTo: _pickTo,
            onSwap: _swap,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PillField(
                  icon: Icons.calendar_today_outlined,
                  label: _formatDate(selectedDate),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PillField(
                  icon: Icons.person_outline,
                  label: '$passengers passager${passengers > 1 ? 's' : ''}',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (_) => _PassengerPicker(
                        value: passengers,
                        onChanged: (v) => setState(() => passengers = v),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (fromRegion == toRegion) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Choisis deux régions différentes')),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResultsScreen(
                      from: fromRegion.name,
                      to: toRegion.name,
                      date: selectedDate,
                    ),
                  ),
                );
              },
              child: const Text('Rechercher'),
            ),
          ),
          const SizedBox(height: 24),
          const PromoBanner(),
          const SizedBox(height: 28),
          Text('Publiés à l\'instant', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: muted)),
          const SizedBox(height: 10),
          const _RecentlyPublished(),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final SenegalRegion fromRegion;
  final SenegalRegion toRegion;
  final VoidCallback onTapFrom;
  final VoidCallback onTapTo;
  final VoidCallback onSwap;

  const _RouteCard({
    required this.fromRegion,
    required this.toRegion,
    required this.onTapFrom,
    required this.onTapTo,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: AppColors.card(context, radius: 20),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
              Container(width: 1.5, height: 34, color: Theme.of(context).dividerColor),
              Icon(Icons.location_on, size: 14, color: AppColors.primary),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _RegionRow(value: fromRegion.name, onTap: onTapFrom),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _RegionRow(value: toRegion.name, onTap: onTapTo),
              ],
            ),
          ),
          IconButton(
            onPressed: onSwap,
            icon: const Icon(Icons.swap_vert, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _RegionRow extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  const _RegionRow({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            Icon(Icons.expand_more, size: 18, color: AppColors.muted(context)),
          ],
        ),
      ),
    );
  }
}

class _PillField extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillField({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: AppColors.card(context, radius: 16),
        child: Row(
          children: [
            Icon(icon, size: 17, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassengerPicker extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _PassengerPicker({required this.value, required this.onChanged});

  @override
  State<_PassengerPicker> createState() => _PassengerPickerState();
}

class _PassengerPickerState extends State<_PassengerPicker> {
  late int value = widget.value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Passagers', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: value > 1 ? () => setState(() => value--) : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 60,
                child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              IconButton.filledTonal(
                onPressed: value < 6 ? () => setState(() => value++) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onChanged(value);
                Navigator.pop(context);
              },
              child: const Text('Valider'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyPublished extends StatelessWidget {
  const _RecentlyPublished();

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    return StreamBuilder<List<Ride>>(
      stream: RideRepository.watchRecent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: muted)),
          );
        }
        final rides = snapshot.data ?? [];
        if (rides.isEmpty) {
          return Text('Aucun trajet publié pour l\'instant. Publies-en un !', style: TextStyle(fontSize: 12.5, color: muted));
        }
        return Column(
          children: rides
              .map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RideDetailScreen(rideId: r.id)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: AppColors.flatField(context),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('${r.from} → ${r.to}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                            ),
                            Text('${r.price.toInt()} FCFA', style: TextStyle(fontSize: 12.5, color: muted, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
