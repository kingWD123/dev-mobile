import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Driver {
  final String name;
  final double rating;
  final int trips;
  final Color color;
  final String car;

  const Driver({
    required this.name,
    required this.rating,
    required this.trips,
    required this.color,
    required this.car,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class Ride {
  final String from;
  final String to;
  final LatLng fromLatLng;
  final LatLng toLatLng;
  final DateTime departure;
  final Duration duration;
  final double price;
  final int seatsLeft;
  final Driver driver;
  final bool instantBooking;

  const Ride({
    required this.from,
    required this.to,
    required this.fromLatLng,
    required this.toLatLng,
    required this.departure,
    required this.duration,
    required this.price,
    required this.seatsLeft,
    required this.driver,
    this.instantBooking = false,
  });
}

enum TripStatus { upcoming, past, cancelled }

class Trip {
  final Ride ride;
  final TripStatus status;
  final bool asDriver;

  const Trip({required this.ride, required this.status, this.asDriver = false});
}

class Cities {
  static const abidjanPlateau = LatLng(5.3097, -4.0125);
  static const abidjanCocody = LatLng(5.3400, -3.9800);
  static const abidjanAdjame = LatLng(5.3450, -4.0270);
  static const abidjanMarcory = LatLng(5.2900, -3.9850);
  static const yamoussoukro = LatLng(6.8206, -5.2767);
  static const bouake = LatLng(7.6939, -5.0300);
  static const sanPedro = LatLng(4.7485, -6.6363);
}

final drivers = [
  const Driver(name: 'Aïcha Koné', rating: 4.9, trips: 132, color: Color(0xFF0E8C6F), car: 'Toyota Corolla · Gris'),
  const Driver(name: 'Yannick Boua', rating: 4.7, trips: 58, color: Color(0xFFC97A3D), car: 'Peugeot 208 · Blanc'),
  const Driver(name: 'Nadège Kouassi', rating: 5.0, trips: 210, color: Color(0xFF3E7CB1), car: 'Hyundai i10 · Bleu'),
  const Driver(name: 'Ismaël Traoré', rating: 4.6, trips: 41, color: Color(0xFF8B6BB0), car: 'Renault Clio · Noir'),
];

final today = DateTime.now();

final List<Ride> mockRides = [
  Ride(
    from: 'Abidjan, Plateau',
    to: 'Yamoussoukro',
    fromLatLng: Cities.abidjanPlateau,
    toLatLng: Cities.yamoussoukro,
    departure: DateTime(today.year, today.month, today.day, 7, 30),
    duration: const Duration(hours: 3, minutes: 10),
    price: 4500,
    seatsLeft: 2,
    driver: drivers[0],
    instantBooking: true,
  ),
  Ride(
    from: 'Abidjan, Cocody',
    to: 'Yamoussoukro',
    fromLatLng: Cities.abidjanCocody,
    toLatLng: Cities.yamoussoukro,
    departure: DateTime(today.year, today.month, today.day, 9, 0),
    duration: const Duration(hours: 3, minutes: 30),
    price: 4000,
    seatsLeft: 1,
    driver: drivers[1],
  ),
  Ride(
    from: 'Abidjan, Adjamé',
    to: 'Yamoussoukro',
    fromLatLng: Cities.abidjanAdjame,
    toLatLng: Cities.yamoussoukro,
    departure: DateTime(today.year, today.month, today.day, 13, 15),
    duration: const Duration(hours: 3),
    price: 5000,
    seatsLeft: 3,
    driver: drivers[2],
    instantBooking: true,
  ),
  Ride(
    from: 'Abidjan, Marcory',
    to: 'Yamoussoukro',
    fromLatLng: Cities.abidjanMarcory,
    toLatLng: Cities.yamoussoukro,
    departure: DateTime(today.year, today.month, today.day, 16, 45),
    duration: const Duration(hours: 3, minutes: 20),
    price: 4200,
    seatsLeft: 4,
    driver: drivers[3],
  ),
];

final List<Trip> mockTrips = [
  Trip(ride: mockRides[0], status: TripStatus.upcoming),
  Trip(
    ride: Ride(
      from: 'Bouaké',
      to: 'Abidjan, Plateau',
      fromLatLng: Cities.bouake,
      toLatLng: Cities.abidjanPlateau,
      departure: today.subtract(const Duration(days: 4)),
      duration: const Duration(hours: 4),
      price: 5500,
      seatsLeft: 0,
      driver: drivers[2],
    ),
    status: TripStatus.past,
  ),
  Trip(
    ride: Ride(
      from: 'Abidjan, Plateau',
      to: 'San-Pédro',
      fromLatLng: Cities.abidjanPlateau,
      toLatLng: Cities.sanPedro,
      departure: today.subtract(const Duration(days: 12)),
      duration: const Duration(hours: 5, minutes: 30),
      price: 6000,
      seatsLeft: 0,
      driver: drivers[0],
    ),
    status: TripStatus.past,
    asDriver: true,
  ),
];
