import 'package:flutter/material.dart';
import '../services/user_repository.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mutedColor = AppColors.muted(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: StreamBuilder<UserProfile>(
        stream: UserRepository.watchProfile(),
        builder: (context, snapshot) {
          final profile = snapshot.data ?? const UserProfile();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.15)),
                      child: Center(
                        child: Text(profile.initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 28)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(profile.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      profile.verified ? 'Identité vérifiée' : (profile.verificationRequested ? 'Vérification en cours' : 'Non vérifié'),
                      style: TextStyle(fontSize: 12.5, color: mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: _StatTile(icon: Icons.directions_car_outlined, label: 'En tant que\nconducteur', collection: 'rides', field: 'driverUid')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatTile(icon: Icons.event_seat_outlined, label: 'En tant que\npassager', collection: 'bookings', field: 'uid')),
                ],
              ),
              const SizedBox(height: 26),
              _SectionLabel('Compte'),
              _SettingsCard(children: [
                _NavRow(
                  icon: Icons.person_outline,
                  title: 'Informations personnelles',
                  subtitle: profile.phone.isEmpty ? 'Nom, téléphone' : '${profile.displayName} · ${profile.phone}',
                  onTap: () => _editPersonalInfo(context, profile),
                ),
                _RowDivider(),
                _NavRow(
                  icon: Icons.directions_car_filled_outlined,
                  title: 'Mon véhicule',
                  subtitle: profile.car.isEmpty ? 'Non renseigné' : profile.car,
                  onTap: () => _editCar(context, profile),
                ),
                _RowDivider(),
                _NavRow(
                  icon: Icons.verified_user_outlined,
                  title: 'Vérification d\'identité',
                  subtitle: profile.verified ? 'Vérifié' : (profile.verificationRequested ? 'En cours' : 'Non vérifié'),
                  onTap: () => _requestVerification(context, profile),
                ),
              ]),
              const SizedBox(height: 22),
              _SectionLabel('Préférences de trajet'),
              _SettingsCard(children: [
                _SwitchRow(
                  icon: Icons.smoke_free,
                  title: 'Non-fumeur',
                  value: profile.smokeFree,
                  onChanged: (v) => UserRepository.update({'smokeFree': v}),
                ),
                _RowDivider(),
                _SwitchRow(
                  icon: Icons.pets_outlined,
                  title: 'Animaux acceptés',
                  value: profile.petsAllowed,
                  onChanged: (v) => UserRepository.update({'petsAllowed': v}),
                ),
                _RowDivider(),
                _SwitchRow(
                  icon: Icons.music_note_outlined,
                  title: 'Musique pendant le trajet',
                  value: profile.music,
                  onChanged: (v) => UserRepository.update({'music': v}),
                ),
                _RowDivider(),
                _SwitchRow(
                  icon: Icons.done_all,
                  title: 'Accusés de lecture',
                  value: profile.readReceipts,
                  onChanged: (v) => UserRepository.update({'readReceipts': v}),
                ),
              ]),
              const SizedBox(height: 22),
              _SectionLabel('Application'),
              _SettingsCard(children: [
                _NavRow(icon: Icons.help_outline, title: 'Aide', subtitle: 'FAQ et support', onTap: () => _showInfo(context, 'Aide', 'Pour toute question, contacte l\'équipe du projet DIC2 covoiturage.')),
                _RowDivider(),
                _NavRow(icon: Icons.lock_outline, title: 'Confidentialité', subtitle: 'Vos données', onTap: () => _showInfo(context, 'Confidentialité', 'Les données (trajets, réservations, messages) sont stockées sur Firebase et associées à votre identité anonyme d\'appareil.')),
              ]),
            ],
          );
        },
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _editPersonalInfo(BuildContext context, UserProfile profile) {
    final nameCtrl = TextEditingController(text: profile.name);
    final phoneCtrl = TextEditingController(text: profile.phone);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Informations personnelles'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom')),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Téléphone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              UserRepository.update({'name': nameCtrl.text.trim(), 'phone': phoneCtrl.text.trim()});
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _editCar(BuildContext context, UserProfile profile) {
    final carCtrl = TextEditingController(text: profile.car);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mon véhicule'),
        content: TextField(controller: carCtrl, decoration: const InputDecoration(labelText: 'Ex : Toyota Corolla, gris')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              UserRepository.update({'car': carCtrl.text.trim()});
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _requestVerification(BuildContext context, UserProfile profile) {
    if (profile.verified) {
      _showInfo(context, 'Vérification d\'identité', 'Votre identité est déjà vérifiée.');
      return;
    }
    if (profile.verificationRequested) {
      _showInfo(context, 'Vérification d\'identité', 'Votre demande est en cours de traitement.');
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vérification d\'identité'),
        content: const Text('Envoyer une demande de vérification d\'identité ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              UserRepository.update({'verificationRequested': true});
              Navigator.pop(context);
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String collection;
  final String field;
  const _StatTile({required this.icon, required this.label, required this.collection, required this.field});

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
          StreamBuilder<int>(
            stream: UserRepository.watchCount(collection, field),
            builder: (context, snapshot) => Text('${snapshot.data ?? 0}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
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

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.ink(context)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
          Switch(value: value, activeThumbColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _NavRow({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.ink(context)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11.5, color: muted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: muted),
          ],
        ),
      ),
    );
  }
}
