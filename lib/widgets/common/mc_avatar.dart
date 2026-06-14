import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McAvatar extends StatelessWidget {
  final String initials;
  final Color? color;
  final double size;

  const McAvatar({
    super.key,
    required this.initials,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppTheme.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
