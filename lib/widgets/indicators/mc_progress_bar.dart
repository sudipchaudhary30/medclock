import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McProgressBar extends StatelessWidget {
  final double value;

  const McProgressBar({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: AppTheme.dividerColor,
        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        minHeight: 8,
      ),
    );
  }
}
