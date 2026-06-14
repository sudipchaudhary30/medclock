import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/mc_scaffold.dart';

class PharmacyMapScreen extends StatelessWidget {
  const PharmacyMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const McScaffold(
      title: 'Pharmacy Finder',
      showBackButton: true,
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find Nearby Pharmacies', style: AppTheme.heading2),
            SizedBox(height: 16),
            Text('Map finder displaying nearby stores matching drug stocks.', style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
