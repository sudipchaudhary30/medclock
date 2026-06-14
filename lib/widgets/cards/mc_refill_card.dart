import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/refill_model.dart';

class McRefillCard extends StatelessWidget {
  final String medicationName;
  final RefillModel refill;
  final VoidCallback? onTap;

  const McRefillCard({
    super.key,
    required this.medicationName,
    required this.refill,
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
          border: Border.all(
            color: refill.isUrgent ? AppTheme.errorColor : AppTheme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_statusIcon, color: _statusColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicationName,
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(_statusText, style: AppTheme.bodySmall),
                  if (refill.estimatedCost != null)
                    Text(
                      'Est. cost: \$${refill.estimatedCost!.toStringAsFixed(2)}',
                      style: AppTheme.caption,
                    ),
                ],
              ),
            ),
            if (refill.isUrgent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (refill.status) {
      case RefillStatus.pending:
        return AppTheme.pendingColor;
      case RefillStatus.ordered:
        return AppTheme.infoColor;
      case RefillStatus.shipped:
        return AppTheme.primaryColor;
      case RefillStatus.delivered:
        return AppTheme.successColor;
    }
  }

  IconData get _statusIcon {
    switch (refill.status) {
      case RefillStatus.pending:
        return Icons.hourglass_empty_rounded;
      case RefillStatus.ordered:
        return Icons.receipt_long_rounded;
      case RefillStatus.shipped:
        return Icons.local_shipping_rounded;
      case RefillStatus.delivered:
        return Icons.check_circle_rounded;
    }
  }

  String get _statusText {
    switch (refill.status) {
      case RefillStatus.pending:
        return 'Pending order';
      case RefillStatus.ordered:
        return 'Order placed';
      case RefillStatus.shipped:
        return 'Shipped';
      case RefillStatus.delivered:
        return 'Delivered';
    }
  }
}
