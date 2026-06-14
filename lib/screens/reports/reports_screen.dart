import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/indicators/mc_adherence_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const McScaffold(
      title: 'Compliance Reports',
      showBackButton: true,
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            McAdherenceChart(
              values: [0.9, 0.8, 1.0, 0.5, 0.9, 1.0, 0.95],
              days: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
            ),
            SizedBox(height: 24),
            Text(
              'Your average weekly adherence score is 86%. Great work!',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
