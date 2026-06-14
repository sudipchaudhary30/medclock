import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../buttons/mc_primary_button.dart';
import '../buttons/mc_secondary_button.dart';

class McConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const McConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTheme.heading3),
      content: Text(message, style: AppTheme.bodyMedium),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        Row(
          children: [
            Expanded(
              child: McSecondaryButton(
                label: cancelLabel,
                onTap: () {
                  Navigator.of(context).pop();
                  if (onCancel != null) onCancel!();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: McPrimaryButton(
                label: confirmLabel,
                onTap: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
