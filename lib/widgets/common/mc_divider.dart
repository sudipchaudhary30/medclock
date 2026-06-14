import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McDivider extends StatelessWidget {
  const McDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppTheme.dividerColor,
      height: 1,
    );
  }
}
