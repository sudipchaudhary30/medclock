import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/medication_model.dart';
import '../buttons/mc_snooze_button.dart';
import '../indicators/mc_streak_badge.dart';
import '../media/mc_pill_image.dart';
import '../common/mc_similarity_warning.dart';

class McReminderCard extends StatelessWidget {
  final MedicationModel medication;
  final String scheduledTime;
  final int streakCount;
  final int snoozesRemaining;
  final List<String> similarMedNames;
  final VoidCallback? onConfirm;
  final VoidCallback? onSnooze;
  final VoidCallback? onCamera;
  final VoidCallback? onMissed;

  const McReminderCard({
    super.key,
    required this.medication,
    required this.scheduledTime,
    this.streakCount = 0,
    this.snoozesRemaining = 2,
    this.similarMedNames = const [],
    this.onConfirm,
    this.onSnooze,
    this.onCamera,
    this.onMissed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Similar pill warning
          if (similarMedNames.isNotEmpty)
            McSimilarityWarning(similarMedNames: similarMedNames),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time & Streak
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 18, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(scheduledTime, style: AppTheme.bodySmall),
                      ],
                    ),
                    if (streakCount > 0)
                      McStreakBadge(count: streakCount),
                  ],
                ),
                const SizedBox(height: 12),

                // Pill Photo + Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    McPillImage(
                      imageUrl: medication.pillPhotoUrl,
                      size: 72,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.name,
                            style: AppTheme.heading3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${medication.dosage} · ${medication.form}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (medication.instructions != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              medication.instructions!,
                              style: AppTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Camera Button
                    if (onCamera != null)
                      _ActionButton(
                        icon: Icons.camera_alt_rounded,
                        color: AppTheme.infoColor,
                        onTap: onCamera!,
                      ),
                    if (onCamera != null) const SizedBox(width: 8),

                    // Snooze
                    McSnoozeButton(
                      onTap: onSnooze,
                      snoozesRemaining: snoozesRemaining,
                    ),

                    const Spacer(),

                    // Missed
                    if (onMissed != null)
                      _ActionButton(
                        icon: Icons.close_rounded,
                        color: AppTheme.errorColor,
                        onTap: onMissed!,
                      ),
                    if (onMissed != null) const SizedBox(width: 8),

                    // Confirm (large, primary)
                    Material(
                      color: AppTheme.successColor,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: onConfirm,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          child: Row(
                            children: [
                              Icon(Icons.check_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Taken',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(child: Icon(icon, color: color, size: 22)),
        ),
      ),
    );
  }
}
