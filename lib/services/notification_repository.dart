import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class AppNotification {
  final String title;
  final String body;
  final DateTime time;

  const AppNotification({required this.title, required this.body, required this.time});

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      time: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class NotificationRepository {
  static final _notifications = FirebaseFirestore.instance.collection('notifications');

  static Future<void> notify({required String forUid, required String title, required String body}) {
    return _notifications.add({
      'forUid': forUid,
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<AppNotification>> watchMine() {
    final uid = AuthService.uid;
    if (uid == null) return Stream.value(const []);
    return _notifications
        .where('forUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppNotification.fromMap(d.data())).toList());
  }
}
