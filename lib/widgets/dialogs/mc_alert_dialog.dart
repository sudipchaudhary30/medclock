import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../buttons/mc_primary_button.dart';

class McAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onPressed;

  const McAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'OK',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTheme.heading3),
      content: Text(message, style: AppTheme.bodyMedium),
      actions: [
        McPrimaryButton(
          label: buttonLabel,
          onTap: () {
            Navigator.of(context).pop();
            if (onPressed != null) onPressed!();
          },
        ),
      ],
    );
  }
}
