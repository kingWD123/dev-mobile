import 'ride_models.dart';

class ChatMessage {
  final String text;
  final bool fromMe;
  final DateTime time;

  const ChatMessage({required this.text, required this.fromMe, required this.time});
}

class Conversation {
  final Driver contact;
  final List<ChatMessage> messages;
  final bool unread;

  const Conversation({required this.contact, required this.messages, this.unread = false});

  ChatMessage get lastMessage => messages.last;
}

final _now = DateTime.now();

final List<Conversation> mockConversations = [
  Conversation(
    contact: drivers[0],
    unread: true,
    messages: [
      ChatMessage(text: 'Bonjour ! Je serai devant la pharmacie du Plateau.', fromMe: false, time: _now.subtract(const Duration(minutes: 22))),
      ChatMessage(text: 'Parfait, j\'y serai à 7h25.', fromMe: true, time: _now.subtract(const Duration(minutes: 20))),
      ChatMessage(text: 'Top, à tout à l\'heure 🚗', fromMe: false, time: _now.subtract(const Duration(minutes: 18))),
    ],
  ),
  Conversation(
    contact: drivers[1],
    messages: [
      ChatMessage(text: 'Merci pour le trajet d\'hier, c\'était nickel.', fromMe: true, time: _now.subtract(const Duration(hours: 20))),
      ChatMessage(text: 'Avec plaisir, à bientôt !', fromMe: false, time: _now.subtract(const Duration(hours: 19, minutes: 50))),
    ],
  ),
  Conversation(
    contact: drivers[2],
    messages: [
      ChatMessage(text: 'Est-ce que vous acceptez un bagage supplémentaire ?', fromMe: true, time: _now.subtract(const Duration(days: 2))),
      ChatMessage(text: 'Oui, pas de souci tant que ça reste raisonnable 👍', fromMe: false, time: _now.subtract(const Duration(days: 2, hours: -1))),
    ],
  ),
];
