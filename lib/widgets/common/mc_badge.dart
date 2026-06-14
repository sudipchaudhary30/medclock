import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McBadge extends StatelessWidget {
  final String status;

  const McBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'taken':
        bgColor = AppTheme.takenColor.withValues(alpha: 0.15);
        textColor = AppTheme.takenColor;
        break;
      case 'missed':
        bgColor = AppTheme.missedColor.withValues(alpha: 0.15);
        textColor = AppTheme.missedColor;
        break;
      case 'skipped':
        bgColor = AppTheme.skippedColor.withValues(alpha: 0.15);
        textColor = AppTheme.skippedColor;
        break;
      default:
        bgColor = AppTheme.pendingColor.withValues(alpha: 0.15);
        textColor = AppTheme.pendingColor;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
