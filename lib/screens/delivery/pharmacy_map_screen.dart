import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/layout/mc_scaffold.dart';

class PharmacyMapScreen extends StatefulWidget {
  const PharmacyMapScreen({super.key});

  @override
  State<PharmacyMapScreen> createState() => _PharmacyMapScreenState();
}

class _PharmacyMapScreenState extends State<PharmacyMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco sample
    zoom: 13.5,
  );

  final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('pharmacy'),
      position: const LatLng(37.7758, -122.435),
      infoWindow: const InfoWindow(title: 'Neighborhood Pharmacy'),
    ),
    Marker(
      markerId: const MarkerId('courier'),
      position: const LatLng(37.770, -122.41),
      infoWindow: const InfoWindow(title: 'Courier (Marcus J.)'),
    ),
  };

  Widget _buildTimelineStep(
    String title,
    String subtitle,
    bool completed, {
    bool isCurrent = false,
  }) {
    final Color primary = const Color(0xFF0E6B94);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: completed ? primary : Colors.white,
                border: Border.all(
                  color: completed
                      ? primary
                      : (isCurrent ? primary : const Color(0xFFCBDCDD)),
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 44,
              color: completed ? primary : const Color(0xFFE6EEF2),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: completed ? primary : const Color(0xFF0D1E30),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF6F7D8E), fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Constrain content width for better layout on wide screens
    return McScaffold(
      title: 'Delivery Tracking',
      showBackButton: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Map area using GoogleMap
                SizedBox(
                  height: 240,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition: _initialPosition,
                      markers: _markers,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        if (!_controller.isCompleted) {
                          _controller.complete(controller);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Delivery Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildTimelineStep(
                  'Order confirmed',
                  'Pharmacy received your order at 10:30 AM',
                  true,
                ),
                const SizedBox(height: 8),
                _buildTimelineStep(
                  'Medication prepared',
                  'Quality check completed by Pharmacist Sarah',
                  true,
                ),
                const SizedBox(height: 8),
                _buildTimelineStep(
                  'Out for delivery',
                  'Courier is currently 2.4 miles away from you',
                  false,
                  isCurrent: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calling courier...')),
                          );
                        },
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text('Call Courier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E6B94),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Need help with your order?',
                    style: TextStyle(color: Color(0xFF9AA7B3), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
