import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/chat_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/driver_avatar.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String contactName;
  final String otherUid;
  const ChatScreen({super.key, required this.conversationId, required this.contactName, required this.otherUid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ChatRepository.send(widget.conversationId, text);
    _controller.clear();
  }

  Future<void> _call() async {
    final snap = await FirebaseFirestore.instance.collection('users').doc(widget.otherUid).get();
    final phone = snap.data()?['phone'] as String?;
    if (!mounted) return;
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.contactName} n\'a pas renseigné de numéro')),
      );
      return;
    }
    await launchUrl(Uri(scheme: 'tel', path: phone.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final myUid = AuthService.uid;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            DriverAvatar(name: widget.contactName, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.contactName,
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined, size: 20), onPressed: _call),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<LiveMessage>>(
              stream: ChatRepository.watch(widget.conversationId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? const [];
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Dites bonjour à ${widget.contactName} 👋',
                      style: TextStyle(color: AppColors.muted(context), fontSize: 13),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[messages.length - 1 - i];
                    return _Bubble(text: msg.text, time: msg.time, fromMe: msg.senderUid == myUid);
                  },
                );
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
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 15),
                        onSubmitted: (_) => _send(),
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
                      onPressed: _send,
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
  final String text;
  final DateTime time;
  final bool fromMe;
  const _Bubble({required this.text, required this.time, required this.fromMe});

  String _time(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final mine = fromMe;
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
            Text(text, style: TextStyle(color: fg, fontSize: 15, height: 1.3)),
            const SizedBox(height: 4),
            Text(_time(time), style: TextStyle(fontSize: 10.5, color: timeColor)),
          ],
        ),
      ),
    );
  }
}
