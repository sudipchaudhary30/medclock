import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/medication_model.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/media/mc_pill_image.dart';

class MedicationDetailScreen extends StatelessWidget {
  const MedicationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medication = ModalRoute.of(context)!.settings.arguments as MedicationModel;

    return McScaffold(
      title: medication.name,
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: McPillImage(
                imageUrl: medication.pillPhotoUrl,
                size: 120,
              ),
            ),
            const SizedBox(height: 24),
            Text('Dosage', style: AppTheme.labelText),
            const SizedBox(height: 6),
            Text(medication.dosage, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Form', style: AppTheme.labelText),
            const SizedBox(height: 6),
            Text(medication.form.toUpperCase(), style: AppTheme.bodyLarge),
            if (medication.instructions != null && medication.instructions!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Instructions', style: AppTheme.labelText),
              const SizedBox(height: 6),
              Text(medication.instructions!, style: AppTheme.bodyMedium),
            ],
            const SizedBox(height: 20),
            Text('Remaining Supply', style: AppTheme.labelText),
            const SizedBox(height: 6),
            Text('${medication.currentSupply} of ${medication.totalSupply} doses', style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
