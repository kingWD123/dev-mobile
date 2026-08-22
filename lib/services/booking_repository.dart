import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'chat_repository.dart';
import 'notification_repository.dart';
import 'ride_repository.dart';
import 'user_repository.dart';

class BookedTrip {
  final String rideId;
  final String from;
  final String to;
  final DateTime departure;
  final double price;
  final String driverUid;
  final String driverName;

  const BookedTrip({
    required this.rideId,
    required this.from,
    required this.to,
    required this.departure,
    required this.price,
    required this.driverUid,
    required this.driverName,
  });

  factory BookedTrip.fromMap(Map<String, dynamic> map) {
    return BookedTrip(
      rideId: map['rideId'] as String? ?? '',
      from: map['from'] as String? ?? '',
      to: map['to'] as String? ?? '',
      departure: (map['departure'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      driverUid: map['driverUid'] as String? ?? '',
      driverName: map['driverName'] as String? ?? '',
    );
  }
}

class BookingRepository {
  static final _bookings = FirebaseFirestore.instance.collection('bookings');

  static Future<bool> book(Ride ride) async {
    final gotSeat = await RideRepository.takeSeat(ride.id);
    if (!gotSeat) return false;

    final myProfile = await UserRepository.fetchProfile();
    final myUid = AuthService.uid ?? 'anon';

    await _bookings.add({
      'uid': myUid,
      'rideId': ride.id,
      'from': ride.from,
      'to': ride.to,
      'departure': Timestamp.fromDate(ride.departure),
      'price': ride.price,
      'driverUid': ride.driverUid,
      'driverName': ride.driverName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await NotificationRepository.notify(
      forUid: ride.driverUid,
      title: 'Nouvelle réservation',
      body: '${myProfile.displayName} a réservé votre trajet ${ride.from} → ${ride.to}.',
    );

    await ChatRepository.ensureConversation(
      otherUid: ride.driverUid,
      otherName: ride.driverName,
      myName: myProfile.displayName,
    );

    return true;
  }

  static Stream<List<BookedTrip>> watchMyBookings() {
    final uid = AuthService.uid;
    if (uid == null) return Stream.value(const []);
    return _bookings
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => BookedTrip.fromMap(d.data())).toList());
  }
}
