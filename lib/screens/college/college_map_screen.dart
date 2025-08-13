import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/college.dart';

class CollegeMapScreen extends StatelessWidget {
  final List<College> colleges;

  const CollegeMapScreen({super.key, required this.colleges});

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];
    for (final c in colleges) {
      final meta = c.metadata ?? {};
      final lat = meta['lat'] as num?;
      final lng = meta['lng'] as num?;
      if (lat != null && lng != null) {
        markers.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(lat.toDouble(), lng.toDouble()),
            child: Tooltip(
              message: c.name,
              child: const Icon(Icons.location_on, color: Colors.red, size: 32),
            ),
          ),
        );
      }
    }

    final center = markers.isNotEmpty
        ? markers.first.point
        : const LatLng(27.7172, 85.3240); // Kathmandu default

    return Scaffold(
      appBar: AppBar(title: const Text('Colleges Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}