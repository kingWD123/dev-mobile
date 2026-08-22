import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class LiveMessage {
  final String text;
  final String senderUid;
  final DateTime time;

  const LiveMessage({required this.text, required this.senderUid, required this.time});

  factory LiveMessage.fromMap(Map<String, dynamic> map) {
    return LiveMessage(
      text: map['text'] as String? ?? '',
      senderUid: map['senderUid'] as String? ?? '',
      time: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ChatConversation {
  final String id;
  final String otherUid;
  final String otherName;
  final String lastMessage;
  final DateTime lastMessageAt;

  const ChatConversation({
    required this.id,
    required this.otherUid,
    required this.otherName,
    required this.lastMessage,
    required this.lastMessageAt,
  });
}

class ChatRepository {
  static final _conversations = FirebaseFirestore.instance.collection('conversations');

  static String conversationIdFor(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  static Future<String> ensureConversation({
    required String otherUid,
    required String otherName,
    required String myName,
  }) async {
    final me = AuthService.uid ?? 'anon';
    final id = conversationIdFor(me, otherUid);
    final doc = _conversations.doc(id);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'participantUids': [me, otherUid],
        'participantNames': {me: myName, otherUid: otherName},
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    }
    return id;
  }

  static CollectionReference<Map<String, dynamic>> _messages(String conversationId) =>
      _conversations.doc(conversationId).collection('messages');

  static Future<void> send(String conversationId, String text) async {
    final me = AuthService.uid ?? 'anon';
    await _messages(conversationId).add({
      'text': text,
      'senderUid': me,
      'sentAt': FieldValue.serverTimestamp(),
    });
    await _conversations.doc(conversationId).set({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<List<LiveMessage>> watch(String conversationId) {
    return _messages(conversationId).orderBy('sentAt').snapshots().map(
          (snap) => snap.docs.map((d) => LiveMessage.fromMap(d.data())).toList(),
        );
  }

  static Stream<List<ChatConversation>> watchMine() {
    final me = AuthService.uid;
    if (me == null) return Stream.value(const []);
    return _conversations
        .where('participantUids', arrayContains: me)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final map = d.data();
              final participants = Map<String, dynamic>.from(map['participantNames'] as Map? ?? {});
              final uids = List<String>.from(map['participantUids'] as List? ?? []);
              final otherUid = uids.firstWhere((u) => u != me, orElse: () => '');
              return ChatConversation(
                id: d.id,
                otherUid: otherUid,
                otherName: participants[otherUid] as String? ?? 'Contact',
                lastMessage: map['lastMessage'] as String? ?? '',
                lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              );
            }).toList());
  }
}
