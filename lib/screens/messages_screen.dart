import 'package:flutter/material.dart';
import '../models/message_models.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_avatar.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  String _time(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.muted(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: mockConversations.length,
        separatorBuilder: (_, _) => Divider(height: 1, indent: 84, color: Theme.of(context).dividerColor),
        itemBuilder: (context, i) {
          final convo = mockConversations[i];
          return InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(conversation: convo))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  DriverAvatar(driver: convo.contact, size: 50),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(convo.contact.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 3),
                        Text(
                          convo.lastMessage.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: muted,
                            fontWeight: convo.unread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_time(convo.lastMessage.time), style: TextStyle(fontSize: 11.5, color: muted)),
                      const SizedBox(height: 8),
                      if (convo.unread)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
