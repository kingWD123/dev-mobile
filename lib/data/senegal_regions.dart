import 'package:latlong2/latlong.dart';

/// The 14 administrative regions of Senegal, each identified by the
/// coordinates of its chief town. Kept as a fixed list so that ride
/// publishing/search never depends on free-text city entry or on an
/// external geocoder: coordinates are always known and always inside
/// Senegal.
class SenegalRegion {
  final String name;
  final LatLng latLng;

  const SenegalRegion(this.name, this.latLng);

  @override
  bool operator ==(Object other) => other is SenegalRegion && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

class SenegalRegions {
  SenegalRegions._();

  static const all = <SenegalRegion>[
    SenegalRegion('Dakar', LatLng(14.6928, -17.4467)),
    SenegalRegion('Thiès', LatLng(14.7910, -16.9359)),
    SenegalRegion('Diourbel', LatLng(14.6529, -16.2312)),
    SenegalRegion('Fatick', LatLng(14.3390, -16.4111)),
    SenegalRegion('Kaffrine', LatLng(14.1059, -15.5508)),
    SenegalRegion('Kaolack', LatLng(14.1652, -16.0726)),
    SenegalRegion('Kédougou', LatLng(12.5556, -12.1747)),
    SenegalRegion('Kolda', LatLng(12.8983, -14.9412)),
    SenegalRegion('Louga', LatLng(15.6173, -16.2240)),
    SenegalRegion('Matam', LatLng(15.6559, -13.2548)),
    SenegalRegion('Saint-Louis', LatLng(16.0326, -16.4818)),
    SenegalRegion('Sédhiou', LatLng(12.7081, -15.5569)),
    SenegalRegion('Tambacounda', LatLng(13.7707, -13.6673)),
    SenegalRegion('Ziguinchor', LatLng(12.5833, -16.2719)),
  ];

  static SenegalRegion byName(String name) =>
      all.firstWhere((r) => r.name == name, orElse: () => all.first);
}
