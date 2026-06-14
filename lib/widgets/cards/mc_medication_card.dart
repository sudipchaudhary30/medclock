import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/medication_model.dart';
import '../media/mc_pill_image.dart';
import '../indicators/mc_supply_indicator.dart';

class McMedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final int dosesPerDay;
  final VoidCallback? onTap;

  const McMedicationCard({
    super.key,
    required this.medication,
    this.dosesPerDay = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            McPillImage(imageUrl: medication.pillPhotoUrl, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${medication.dosage} · ${medication.form}',
                    style: AppTheme.bodySmall,
                  ),
                  if (medication.currentSupply > 0) ...[
                    const SizedBox(height: 8),
                    McSupplyIndicator(
                      current: medication.currentSupply,
                      total: medication.totalSupply,
                      threshold: medication.refillThreshold,
                      dosesPerDay: dosesPerDay,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textHint,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
