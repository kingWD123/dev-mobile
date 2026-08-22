import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'auth_service.dart';
import 'firestore_safe.dart';

class Ride {
  final String id;
  final String from;
  final String to;
  final LatLng fromLatLng;
  final LatLng toLatLng;
  final DateTime departure;
  final Duration duration;
  final double price;
  final int seats;
  final int seatsTotal;
  final bool instantBooking;
  final String driverUid;
  final String driverName;
  final String driverCar;

  const Ride({
    required this.id,
    required this.from,
    required this.to,
    required this.fromLatLng,
    required this.toLatLng,
    required this.departure,
    required this.duration,
    required this.price,
    required this.seats,
    required this.seatsTotal,
    required this.instantBooking,
    required this.driverUid,
    required this.driverName,
    required this.driverCar,
  });

  factory Ride.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    return Ride(
      id: doc.id,
      from: map['from'] as String? ?? '',
      to: map['to'] as String? ?? '',
      fromLatLng: LatLng((map['fromLat'] as num?)?.toDouble() ?? 0, (map['fromLng'] as num?)?.toDouble() ?? 0),
      toLatLng: LatLng((map['toLat'] as num?)?.toDouble() ?? 0, (map['toLng'] as num?)?.toDouble() ?? 0),
      departure: (map['departure'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: Duration(minutes: map['durationMinutes'] as int? ?? 60),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      seats: map['seats'] as int? ?? 0,
      seatsTotal: map['seatsTotal'] as int? ?? (map['seats'] as int? ?? 0),
      instantBooking: map['instantBooking'] as bool? ?? false,
      driverUid: map['driverUid'] as String? ?? '',
      driverName: map['driverName'] as String? ?? 'Conducteur',
      driverCar: map['driverCar'] as String? ?? '',
    );
  }
}

class RideRepository {
  static CollectionReference<Map<String, dynamic>>? get _rides => safeFirestore()?.collection('rides');

  static Duration _estimateDuration(LatLng from, LatLng to) {
    final km = const Distance().as(LengthUnit.Kilometer, from, to);
    final hours = km / 55;
    return Duration(minutes: (hours * 60).round().clamp(15, 24 * 60));
  }

  static Future<void> publish({
    required String from,
    required String to,
    required LatLng fromLatLng,
    required LatLng toLatLng,
    required DateTime departure,
    required int seats,
    required double price,
    required bool instantBooking,
    required String driverName,
    required String driverCar,
  }) async {
    final rides = _rides;
    if (rides == null) return;
    final duration = _estimateDuration(fromLatLng, toLatLng);
    await rides.add({
      'from': from,
      'to': to,
      'fromLat': fromLatLng.latitude,
      'fromLng': fromLatLng.longitude,
      'toLat': toLatLng.latitude,
      'toLng': toLatLng.longitude,
      'departure': Timestamp.fromDate(departure),
      'durationMinutes': duration.inMinutes,
      'seats': seats,
      'seatsTotal': seats,
      'price': price,
      'instantBooking': instantBooking,
      'driverUid': AuthService.uid ?? 'anon',
      'driverName': driverName,
      'driverCar': driverCar,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<Ride>> watchAll() {
    final rides = _rides;
    if (rides == null) return Stream.value(const []);
    return rides.orderBy('createdAt', descending: true).limit(50).snapshots().map(
          (snap) => snap.docs.map(Ride.fromDoc).toList(),
        );
  }

  static Stream<List<Ride>> watchRecent() {
    final rides = _rides;
    if (rides == null) return Stream.value(const []);
    return rides.orderBy('createdAt', descending: true).limit(6).snapshots().map(
          (snap) => snap.docs.map(Ride.fromDoc).toList(),
        );
  }

  static Stream<Ride?> watchOne(String id) {
    final rides = _rides;
    if (rides == null) return Stream.value(null);
    return rides.doc(id).snapshots().map((snap) => snap.exists ? Ride.fromDoc(snap) : null);
  }

  static Stream<List<Ride>> watchMine() {
    final uid = AuthService.uid;
    final rides = _rides;
    if (uid == null || rides == null) return Stream.value(const []);
    return rides.where('driverUid', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(Ride.fromDoc).toList(),
        );
  }

  static Future<bool> takeSeat(String rideId) {
    final rides = _rides;
    final db = safeFirestore();
    if (rides == null || db == null) return Future.value(false);
    final ref = rides.doc(rideId);
    return db.runTransaction<bool>((tx) async {
      final snap = await tx.get(ref);
      final seats = snap.data()?['seats'] as int? ?? 0;
      if (seats <= 0) return false;
      tx.update(ref, {'seats': seats - 1});
      return true;
    });
  }
}
