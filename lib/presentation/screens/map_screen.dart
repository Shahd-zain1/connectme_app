import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/member_marker.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Map')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(25, 10),
          zoom: 2,
        ),
        markers: buildMemberMarkers(hardcodedMembers),
      ),
    );
  }
}
