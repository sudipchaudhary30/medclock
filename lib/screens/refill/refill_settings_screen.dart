import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/inputs/mc_text_field.dart';
import '../../widgets/buttons/mc_primary_button.dart';

class RefillSettingsScreen extends StatelessWidget {
  const RefillSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return McScaffold(
      title: 'Refill Config',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Auto-Refill Settings', style: AppTheme.heading2),
            const SizedBox(height: 8),
            Text(
              'Set global thresholds to request prescription refills before your medications run out.',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            const McTextField(
              label: 'Refill Request Threshold (Days Supply)',
              hint: 'e.g. 7 days',
            ),
            const Spacer(),
            McPrimaryButton(
              label: 'Save Configuration',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
