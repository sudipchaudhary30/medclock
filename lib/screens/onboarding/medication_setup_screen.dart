import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../widgets/buttons/mc_primary_button.dart';
import '../../widgets/buttons/mc_text_button.dart';

class MedicationSetupScreen extends StatelessWidget {
  const MedicationSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Medications')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.medication_liquid_rounded,
              size: 100,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 32),
            Text(
              'Add your first medication',
              style: AppTheme.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Configure doses, scheduled times, pill photographs, and thresholds to get started.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            McPrimaryButton(
              label: 'Add Medication',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.addMedication),
            ),
            const SizedBox(height: 16),
            McTextButton(
              label: 'Configure Later',
              onTap: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
            ),
          ],
        ),
      ),
    );
  }
}
