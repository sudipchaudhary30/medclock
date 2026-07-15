import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../widgets/layout/caregiver_app_bar.dart';

class DailySummaryScreen extends StatelessWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: const CaregiverAppBar(showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Daily Status Update', style: AppTheme.heading2),
              SizedBox(height: 16),
              Text(
                'Here is the summarized report of medication compliance for today.',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
