import 'package:google_maps_flutter/google_maps_flutter.dart';

// Plain data for one hardcoded member location, kept separate from the
// Marker objects themselves since a Marker also needs callbacks
// (onTap, InfoWindow) that don't belong in a data class.
class MemberLocation {
  const MemberLocation({required this.name, required this.city, required this.position});

  final String name;
  final String city;
  final LatLng position;
}

const List<MemberLocation> hardcodedMembers = [
  MemberLocation(name: 'Sara Adel', city: 'Cairo', position: LatLng(30.0444, 31.2357)),
  MemberLocation(name: 'James Whitfield', city: 'London', position: LatLng(51.5072, -0.1276)),
  MemberLocation(name: 'Maria Gonzalez', city: 'New York', position: LatLng(40.7128, -74.0060)),
];

// Builds the actual Marker set MapScreen passes to GoogleMap, tapping a
// marker shows its InfoWindow with the member's name and city.
Set<Marker> buildMemberMarkers(List<MemberLocation> members) {
  return members
      .map(
        (member) => Marker(
          markerId: MarkerId(member.name),
          position: member.position,
          infoWindow: InfoWindow(title: member.name, snippet: member.city),
        ),
      )
      .toSet();
}
