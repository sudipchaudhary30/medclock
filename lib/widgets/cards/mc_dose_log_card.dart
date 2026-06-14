import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/dose_log_model.dart';
import '../common/mc_badge.dart';
import 'package:intl/intl.dart';

class McDoseLogCard extends StatelessWidget {
  final DoseLogModel doseLog;
  final String medicationName;
  final bool showPhoto;
  final VoidCallback? onTap;

  const McDoseLogCard({
    super.key,
    required this.doseLog,
    required this.medicationName,
    this.showPhoto = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(_statusIcon, color: _statusColor, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicationName,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _timeText,
                    style: AppTheme.caption,
                  ),
                  if (doseLog.isMissed && doseLog.missedReason != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Reason: $_missedReasonText',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.missedColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showPhoto && doseLog.hasPhoto) ...[
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  color: AppTheme.dividerColor,
                  child: const Icon(Icons.photo, size: 20, color: AppTheme.textHint),
                ),
              ),
            ],
            const SizedBox(width: 8),
            McBadge(status: _badgeStatus),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (doseLog.status) {
      case DoseStatus.taken:
        return AppTheme.takenColor;
      case DoseStatus.missed:
        return AppTheme.missedColor;
      case DoseStatus.skipped:
        return AppTheme.skippedColor;
    }
  }

  IconData get _statusIcon {
    switch (doseLog.status) {
      case DoseStatus.taken:
        return Icons.check_circle_rounded;
      case DoseStatus.missed:
        return Icons.cancel_rounded;
      case DoseStatus.skipped:
        return Icons.skip_next_rounded;
    }
  }

  String get _timeText {
    final scheduled = DateFormat('h:mm a').format(doseLog.scheduledAt);
    if (doseLog.confirmedAt != null) {
      final confirmed = DateFormat('h:mm a').format(doseLog.confirmedAt!);
      return 'Scheduled $scheduled · Taken $confirmed';
    }
    return 'Scheduled $scheduled';
  }

  String get _missedReasonText {
    switch (doseLog.missedReason) {
      case MissedReason.forgot:
        return 'Forgot';
      case MissedReason.asleep:
        return 'Asleep';
      case MissedReason.sideEffect:
        return 'Side effect';
      case MissedReason.other:
        return doseLog.missedNote ?? 'Other';
      default:
        return 'Unknown';
    }
  }

  String get _badgeStatus {
    switch (doseLog.status) {
      case DoseStatus.taken:
        return 'taken';
      case DoseStatus.missed:
        return 'missed';
      case DoseStatus.skipped:
        return 'skipped';
    }
  }
}
