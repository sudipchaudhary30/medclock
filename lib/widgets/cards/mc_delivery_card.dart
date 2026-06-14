import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/delivery_model.dart';

class McDeliveryCard extends StatelessWidget {
  final DeliveryModel delivery;
  final String medicationName;
  final VoidCallback? onTap;

  const McDeliveryCard({
    super.key,
    required this.delivery,
    required this.medicationName,
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
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping_rounded,
                    color: AppTheme.primaryColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    medicationName,
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (delivery.courierName != null) ...[
              const SizedBox(height: 8),
              Text('Courier: ${delivery.courierName}', style: AppTheme.bodySmall),
            ],
            if (delivery.estimatedDelivery != null) ...[
              const SizedBox(height: 4),
              Text(
                'ETA: ${_formatDate(delivery.estimatedDelivery!)}',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (delivery.status) {
      case DeliveryStatus.processing:
        return AppTheme.pendingColor;
      case DeliveryStatus.dispatched:
        return AppTheme.infoColor;
      case DeliveryStatus.inTransit:
        return AppTheme.primaryColor;
      case DeliveryStatus.delivered:
        return AppTheme.successColor;
      case DeliveryStatus.failed:
        return AppTheme.errorColor;
    }
  }

  String get _statusText {
    switch (delivery.status) {
      case DeliveryStatus.processing:
        return 'Processing';
      case DeliveryStatus.dispatched:
        return 'Dispatched';
      case DeliveryStatus.inTransit:
        return 'In Transit';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.failed:
        return 'Failed';
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
