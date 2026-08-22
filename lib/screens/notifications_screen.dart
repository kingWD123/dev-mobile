import 'package:flutter/material.dart';
import '../services/notification_repository.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _time(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'maintenant';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<AppNotification>>(
        stream: NotificationRepository.watchMine(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Aucune notification pour l\'instant. Publie ou réserve un trajet pour voir de l\'activité ici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 13.5),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final n = items[i];
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
                      child: const Icon(Icons.notifications_none, color: AppColors.primary, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                              Text(_time(n.time), style: TextStyle(fontSize: 11, color: muted)),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(n.body, style: TextStyle(fontSize: 12.5, color: muted, height: 1.35)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
