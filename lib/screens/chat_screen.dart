import 'package:flutter/material.dart';
import '../models/message_models.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_avatar.dart';

class ChatScreen extends StatelessWidget {
  final Conversation conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            DriverAvatar(driver: conversation.contact, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                conversation.contact.name,
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.call_outlined, size: 20),
          SizedBox(width: 18),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: conversation.messages.length,
              itemBuilder: (context, i) {
                final msg = conversation.messages[conversation.messages.length - 1 - i];
                return _Bubble(message: msg);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: AppColors.card(context, radius: 22),
                      child: TextField(
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Message…',
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  String _time(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final mine = message.fromMe;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = mine ? AppColors.primary : (isDark ? AppColors.chipDark : AppColors.chipLight);
    final fg = mine ? Colors.white : AppColors.ink(context);
    final timeColor = mine ? Colors.white70 : AppColors.muted(context);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.text, style: TextStyle(color: fg, fontSize: 15, height: 1.3)),
            const SizedBox(height: 4),
            Text(_time(message.time), style: TextStyle(fontSize: 10.5, color: timeColor)),
          ],
        ),
      ),
    );
  }
}
