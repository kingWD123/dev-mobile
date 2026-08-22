import 'package:flutter/material.dart';
import '../services/chat_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_avatar.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

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
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<List<ChatConversation>>(
        stream: ChatRepository.watchMine(),
        builder: (context, snapshot) {
          final conversations = snapshot.data ?? const [];
          if (conversations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Aucune conversation pour l\'instant. Réserve ou publie un trajet pour en démarrer une.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 13.5),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: conversations.length,
            separatorBuilder: (_, _) => Divider(height: 1, indent: 84, color: Theme.of(context).dividerColor),
            itemBuilder: (context, i) {
              final convo = conversations[i];
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      conversationId: convo.id,
                      contactName: convo.otherName,
                      otherUid: convo.otherUid,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      DriverAvatar(name: convo.otherName, size: 50),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(convo.otherName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 3),
                            Text(
                              convo.lastMessage.isEmpty ? 'Conversation démarrée' : convo.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: muted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_time(convo.lastMessageAt), style: TextStyle(fontSize: 11.5, color: muted)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
