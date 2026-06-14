import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? label;
  final Color? backgroundColor;

  const McFab({
    super.key,
    required this.icon,
    this.onTap,
    this.label,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onTap,
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: Icon(icon),
        label: Text(label!, style: AppTheme.buttonText.copyWith(color: Colors.white)),
      );
    }
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }
}
