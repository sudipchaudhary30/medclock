import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McSupplyIndicator extends StatelessWidget {
  final int current;
  final int total;
  final int threshold;
  final int dosesPerDay;

  const McSupplyIndicator({
    super.key,
    required this.current,
    required this.total,
    required this.threshold,
    required this.dosesPerDay,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = dosesPerDay > 0 ? (current / dosesPerDay).floor() : current;
    final bool isLow = daysLeft <= threshold;
    final bool isCritical = daysLeft <= 3;

    final color = isCritical
        ? AppTheme.errorColor
        : (isLow ? AppTheme.warningColor : AppTheme.successColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$current/$total doses left',
              style: AppTheme.bodySmall,
            ),
            Text(
              '$daysLeft days left',
              style: AppTheme.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? current / total : 0,
            backgroundColor: AppTheme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
