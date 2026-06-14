import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? textColor;

  const McTextButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppTheme.primaryColor,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTheme.buttonText.copyWith(
              color: textColor ?? AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
