import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/medication_model.dart';
import '../media/mc_pill_image.dart';

class McReminderCard extends StatelessWidget {
  final MedicationModel medication;
  final String scheduledTime;
  final String status;
  final VoidCallback onTap;

  const McReminderCard({
    super.key,
    required this.medication,
    required this.scheduledTime,
    required this.status,
    required this.onTap,
  });

  static String formatReminderTime(String scheduledTime) {
    final parts = scheduledTime.split(':');
    final hour = int.tryParse(parts.first) ?? 8;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final dateTime = DateTime(2000, 1, 1, hour, minute);
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String scheduleLabel(String scheduledTime) {
    final hour = int.tryParse(scheduledTime.split(':').first) ?? 8;
    if (hour < 10) return 'Before Breakfast';
    if (hour < 12) return 'After Breakfast';
    if (hour < 14) return 'Before Lunch';
    if (hour < 17) return 'After Lunch';
    if (hour < 20) return 'Before Dinner';
    return 'After Dinner';
  }

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.trim().toUpperCase();
    final bool isTaken = cleanStatus == 'TAKEN';
    final bool isMissed = cleanStatus == 'MISSED';

    final Color accentBarColor;
    final Color badgeBgColor;
    final Color badgeTextColor;
    final IconData trailingIcon;

    if (isTaken) {
      accentBarColor = const Color(0xFF0D6A95);
      badgeBgColor = const Color(0xFFE1F0F5);
      badgeTextColor = const Color(0xFF0D6A95);
      trailingIcon = Icons.check_rounded;
    } else if (isMissed) {
      accentBarColor = const Color(0xFFFF4757);
      badgeBgColor = const Color(0xFFFFEBEE);
      badgeTextColor = const Color(0xFFFF4757);
      trailingIcon = Icons.close_rounded;
    } else {
      accentBarColor = const Color(0xFF38BDF8);
      badgeBgColor = const Color(0xFFE7F3FB);
      badgeTextColor = const Color(0xFF0D6A95);
      trailingIcon = Icons.add_rounded;
    }

    final formattedTime = formatReminderTime(scheduledTime);
    final label = scheduleLabel(scheduledTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 5,
                  child: Container(
                    color: accentBarColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 18,
                    top: 16,
                    bottom: 16,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        McPillImage(
                          imageUrl: medication.pillPhotoUrl,
                          size: 52,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                medication.name,
                                style: const TextStyle(
                                  color: Color(0xFF0B1A2C),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${medication.dosage} • $label',
                                style: const TextStyle(
                                  color: Color(0xFF2E6B8E),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: Color(0xFF6F7D8E),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(
                                      color: Color(0xFF6F7D8E),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                cleanStatus,
                                style: TextStyle(
                                  color: badgeTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFF006684),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                trailingIcon,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
