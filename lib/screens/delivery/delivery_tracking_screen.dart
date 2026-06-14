import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/mc_scaffold.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const McScaffold(
      title: 'Delivery Tracker',
      showBackButton: true,
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Courier Map Tracking', style: AppTheme.heading2),
            SizedBox(height: 16),
            Text('Courier tracking updates will be refreshed here in real-time.', style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
