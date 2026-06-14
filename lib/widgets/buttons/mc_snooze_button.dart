import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McSnoozeButton extends StatelessWidget {
  final VoidCallback? onTap;
  final int snoozesRemaining;
  final int snoozeMinutes;
  final bool disabled;

  const McSnoozeButton({
    super.key,
    this.onTap,
    this.snoozesRemaining = 2,
    this.snoozeMinutes = 15,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final canSnooze = snoozesRemaining > 0 && !disabled;

    return Material(
      color: canSnooze
          ? AppTheme.warningColor.withValues(alpha: 0.1)
          : AppTheme.disabledColor.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: canSnooze ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.snooze_rounded,
                size: 20,
                color: canSnooze ? AppTheme.warningColor : AppTheme.textHint,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Snooze ${snoozeMinutes}min',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: canSnooze
                          ? AppTheme.warningColor
                          : AppTheme.textHint,
                    ),
                  ),
                  Text(
                    '$snoozesRemaining remaining',
                    style: TextStyle(
                      fontSize: 11,
                      color: canSnooze
                          ? AppTheme.textSecondary
                          : AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
