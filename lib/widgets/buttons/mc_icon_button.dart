import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';

class McIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? badge;
  final String? tooltip;

  const McIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.backgroundColor,
    this.iconColor,
    this.badge,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size < AppConstants.minTouchTarget
        ? AppConstants.minTouchTarget
        : size;

    Widget button = Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(effectiveSize / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveSize / 2),
        child: SizedBox(
          width: effectiveSize,
          height: effectiveSize,
          child: Center(
            child: Icon(
              icon,
              size: effectiveSize * 0.5,
              color: iconColor ?? AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );

    if (badge != null) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
