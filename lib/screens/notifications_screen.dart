import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _NotifItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool unread;

  const _NotifItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unread = false,
  });
}

const _today = [
  _NotifItem(
    icon: Icons.check_circle_outline,
    title: 'Réservation confirmée',
    subtitle: 'Aïcha Koné a accepté votre demande pour Yamoussoukro.',
    time: '12 min',
    unread: true,
  ),
  _NotifItem(
    icon: Icons.chat_bubble_outline,
    title: 'Nouveau message',
    subtitle: 'Aïcha Koné : "Je serai devant la pharmacie du Plateau."',
    time: '22 min',
    unread: true,
  ),
];

const _week = [
  _NotifItem(
    icon: Icons.star_outline,
    title: 'Notez votre trajet',
    subtitle: 'Comment s\'est passé votre trajet avec Nadège Kouassi ?',
    time: '2 j',
  ),
  _NotifItem(
    icon: Icons.local_offer_outlined,
    title: 'Offre spéciale',
    subtitle: '-10% sur votre prochain trajet Abidjan → Bouaké.',
    time: '4 j',
  ),
  _NotifItem(
    icon: Icons.event_seat_outlined,
    title: 'Trajet publié',
    subtitle: 'Votre trajet vers San-Pédro est désormais visible.',
    time: '6 j',
  ),
];

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _SectionLabel('Aujourd\'hui'),
          ..._today.map((n) => _NotifTile(item: n)),
          const SizedBox(height: 20),
          _SectionLabel('Cette semaine'),
          ..._week.map((n) => _NotifTile(item: n)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.muted(context))),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _NotifItem item;
  const _NotifTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppColors.card(context, radius: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: AppColors.flatField(context, radius: 12),
            child: Icon(item.icon, color: AppColors.ink(context), size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                    if (item.unread) ...[
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                    ],
                    Text(item.time, style: TextStyle(fontSize: 11, color: muted)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(item.subtitle, style: TextStyle(fontSize: 12.5, color: muted, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
