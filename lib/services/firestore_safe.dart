import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore? safeFirestore() {
  try {
    return FirebaseFirestore.instance;
  } catch (_) {
    return null;
  }
}
