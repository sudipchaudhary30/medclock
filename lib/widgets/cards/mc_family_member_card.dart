import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/family_member_model.dart';
import '../common/mc_avatar.dart';

class McFamilyMemberCard extends StatelessWidget {
  final FamilyMemberModel member;
  final int? medicationCount;
  final String? lastDoseStatus; // taken, missed, pending
  final VoidCallback? onTap;

  const McFamilyMemberCard({
    super.key,
    required this.member,
    this.medicationCount,
    this.lastDoseStatus,
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
          boxShadow: [
            BoxShadow(
              color: member.color.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            McAvatar(
              initials: member.initials,
              color: member.color,
              size: 48,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.role == 'patient' ? 'Patient' : 'Caregiver',
                    style: AppTheme.caption,
                  ),
                  if (medicationCount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '$medicationCount medication${medicationCount == 1 ? '' : 's'}',
                        style: AppTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            if (lastDoseStatus != null) _buildStatusDot(),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textHint, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot() {
    Color dotColor;
    switch (lastDoseStatus) {
      case 'taken':
        dotColor = AppTheme.takenColor;
        break;
      case 'missed':
        dotColor = AppTheme.missedColor;
        break;
      default:
        dotColor = AppTheme.pendingColor;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
