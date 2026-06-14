import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/mc_scaffold.dart';

class DailySummaryScreen extends StatelessWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const McScaffold(
      title: 'Daily Compliance Summary',
      showBackButton: true,
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Status Update', style: AppTheme.heading2),
            SizedBox(height: 16),
            Text('Here is the summarized report of medication compliance for today.', style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
