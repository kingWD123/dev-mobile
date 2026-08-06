import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PublishRideScreen extends StatefulWidget {
  const PublishRideScreen({super.key});

  @override
  State<PublishRideScreen> createState() => _PublishRideScreenState();
}

class _PublishRideScreenState extends State<PublishRideScreen> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final priceController = TextEditingController();
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  int seats = 3;
  bool instantBooking = true;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) setState(() => time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Publier un trajet')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _Label('Itinéraire'),
          _FormField(controller: fromController, hint: 'Ville de départ', icon: Icons.trip_origin),
          const SizedBox(height: 10),
          _FormField(controller: toController, hint: 'Ville d\'arrivée', icon: Icons.location_on_outlined),
          const SizedBox(height: 22),
          _Label('Date et heure'),
          Row(
            children: [
              Expanded(
                child: _TapField(
                  icon: Icons.calendar_today_outlined,
                  label: '${date.day}/${date.month}/${date.year}',
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TapField(
                  icon: Icons.access_time,
                  label: time.format(context),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _Label('Places disponibles'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: AppColors.card(context, radius: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$seats place${seats > 1 ? 's' : ''}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (seats > 1) {
                          setState(() {
                            seats = seats - 1;
                          });
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                    ),
                    Text('$seats', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    IconButton(
                      onPressed: () {
                        if (seats < 6) {
                          setState(() {
                            seats = seats + 1;
                          });
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _Label('Prix par passager'),
          _FormField(controller: priceController, hint: 'Ex : 4500', icon: Icons.sell_outlined, keyboardType: TextInputType.number, suffix: 'FCFA'),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: AppColors.card(context, radius: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Réservation instantanée', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('Les passagers réservent sans confirmation de votre part', style: TextStyle(fontSize: 11.5, color: muted)),
                    ],
                  ),
                ),
                Switch(
                  value: instantBooking,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() => instantBooking = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trajet publié (aperçu visuel uniquement)')),
                );
              },
              child: const Text('Publier le trajet'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.muted(context)),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? suffix;

  const _FormField({required this.controller, required this.hint, required this.icon, this.keyboardType, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.card(context, radius: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 19, color: AppColors.primary),
          suffixText: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TapField({required this.icon, required this.label, required this.onTap});

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
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
          ],
        ),
      ),
    );
  }
}
