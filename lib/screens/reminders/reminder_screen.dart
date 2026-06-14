import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/mc_scaffold.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const McScaffold(
      title: 'Active Reminder',
      showBackButton: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alarm_rounded, size: 64, color: AppTheme.primaryColor),
            SizedBox(height: 16),
            Text('No active reminder fired.', style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
