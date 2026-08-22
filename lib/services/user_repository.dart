import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class UserProfile {
  final String name;
  final String phone;
  final String car;
  final bool smokeFree;
  final bool petsAllowed;
  final bool music;
  final bool readReceipts;
  final bool verified;
  final bool verificationRequested;

  const UserProfile({
    this.name = '',
    this.phone = '',
    this.car = '',
    this.smokeFree = false,
    this.petsAllowed = false,
    this.music = false,
    this.readReceipts = false,
    this.verified = false,
    this.verificationRequested = false,
  });

  factory UserProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserProfile();
    return UserProfile(
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      car: map['car'] as String? ?? '',
      smokeFree: map['smokeFree'] as bool? ?? false,
      petsAllowed: map['petsAllowed'] as bool? ?? false,
      music: map['music'] as bool? ?? false,
      readReceipts: map['readReceipts'] as bool? ?? false,
      verified: map['verified'] as bool? ?? false,
      verificationRequested: map['verificationRequested'] as bool? ?? false,
    );
  }

  String get displayName => name.trim().isEmpty ? 'Nouvel utilisateur' : name;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class UserRepository {
  static DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = AuthService.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  static Stream<UserProfile> watchProfile() {
    final doc = _doc;
    if (doc == null) return Stream.value(const UserProfile());
    return doc.snapshots().map((snap) => UserProfile.fromMap(snap.data()));
  }

  static Future<UserProfile> fetchProfile() async {
    final doc = _doc;
    if (doc == null) return const UserProfile();
    final snap = await doc.get();
    return UserProfile.fromMap(snap.data());
  }

  static Future<void> update(Map<String, dynamic> fields) async {
    final doc = _doc;
    if (doc == null) return;
    await doc.set(fields, SetOptions(merge: true));
  }

  static Stream<int> watchCount(String collection, String field) {
    final uid = AuthService.uid;
    if (uid == null) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection(collection)
        .where(field, isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
