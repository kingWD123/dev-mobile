import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/promo_banner.dart';
import 'notifications_screen.dart';
import 'results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final fromController = TextEditingController(text: 'Abidjan, Plateau');
  final toController = TextEditingController(text: 'Yamoussoukro');
  DateTime selectedDate = DateTime.now();
  int passengers = 1;

  void _swap() {
    final tmp = fromController.text;
    setState(() {
      fromController.text = toController.text;
      toController.text = tmp;
    });
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
            fromController: fromController,
            toController: toController,
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResultsScreen(
                      from: fromController.text,
                      to: toController.text,
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
          Text('Trajets populaires', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: muted)),
          const SizedBox(height: 10),
          _PopularRoute(from: 'Abidjan', to: 'Yamoussoukro', price: '4 000 FCFA'),
          _PopularRoute(from: 'Abidjan', to: 'Bouaké', price: '5 000 FCFA'),
          _PopularRoute(from: 'Abidjan', to: 'San-Pédro', price: '6 000 FCFA'),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final TextEditingController fromController;
  final TextEditingController toController;
  final VoidCallback onSwap;

  const _RouteCard({required this.fromController, required this.toController, required this.onSwap});

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
                TextField(
                  controller: fromController,
                  decoration: const InputDecoration(
                    hintText: 'Départ',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                TextField(
                  controller: toController,
                  decoration: const InputDecoration(
                    hintText: 'Arrivée',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
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

class _PopularRoute extends StatelessWidget {
  final String from;
  final String to;
  final String price;
  const _PopularRoute({required this.from, required this.to, required this.price});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: AppColors.flatField(context),
        child: Row(
          children: [
            const Icon(Icons.trending_up, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text('$from → $to', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            ),
            Text('dès $price', style: TextStyle(fontSize: 12.5, color: muted, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
