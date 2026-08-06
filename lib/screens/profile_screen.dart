import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.15)),
                  child: const Center(
                    child: Text('SK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 28)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Soro Konan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Membre depuis janvier 2026', style: TextStyle(fontSize: 12.5, color: muted)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 15, color: AppColors.rating),
                    const SizedBox(width: 4),
                    const Text('4.8', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    Text('  ·  27 trajets', style: TextStyle(fontSize: 13, color: muted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _StatTile(icon: Icons.directions_car_outlined, label: 'En tant que\nconducteur', value: '9')),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(icon: Icons.event_seat_outlined, label: 'En tant que\npassager', value: '18')),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(icon: Icons.eco_outlined, label: 'CO₂\néconomisé', value: '46kg')),
            ],
          ),
          const SizedBox(height: 26),
          _SectionLabel('Compte'),
          _SettingsCard(children: const [
            _NavRow(icon: Icons.person_outline, title: 'Informations personnelles'),
            _RowDivider(),
            _NavRow(icon: Icons.directions_car_filled_outlined, title: 'Mon véhicule'),
            _RowDivider(),
            _NavRow(icon: Icons.verified_user_outlined, title: 'Vérification d\'identité'),
          ]),
          const SizedBox(height: 22),
          _SectionLabel('Préférences'),
          _SettingsCard(children: const [
            _NavRow(icon: Icons.smoke_free, title: 'Non-fumeur'),
            _RowDivider(),
            _NavRow(icon: Icons.pets_outlined, title: 'Animaux acceptés'),
            _RowDivider(),
            _NavRow(icon: Icons.music_note_outlined, title: 'Musique pendant le trajet'),
          ]),
          const SizedBox(height: 22),
          _SectionLabel('Application'),
          _SettingsCard(children: const [
            _NavRow(icon: Icons.notifications_none, title: 'Notifications'),
            _RowDivider(),
            _NavRow(icon: Icons.lock_outline, title: 'Confidentialité'),
            _RowDivider(),
            _NavRow(icon: Icons.help_outline, title: 'Aide'),
          ]),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: AppColors.flatField(context),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.ink(context)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: muted, height: 1.2)),
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
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.muted(context))),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.card(context, radius: 18),
      child: Column(children: children),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 52, color: Theme.of(context).dividerColor);
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  const _NavRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.ink(context)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, size: 18, color: muted),
          ],
        ),
      ),
    );
  }
}
