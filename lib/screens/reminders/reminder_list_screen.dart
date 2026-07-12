import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../../providers/medication_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/dose_log_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/cards/mc_reminder_card.dart';

class ReminderListScreen extends ConsumerWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderProvider);
    final medications = ref.watch(medicationProvider);
    final doseLogs = ref.watch(doseLogProvider);

    final now = DateTime.now();
    final todayWeekday = _weekdayAbbrev(now);
    final todayWeekdayFull = _weekdayFullName(now);
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // Filter reminders to only include those that match an existing, added medication
    final activeReminders = reminders.where((r) {
      return medications.any((m) => m.id == r.medicationId);
    }).toList();

    return McScaffold(
      title: 'Reminder Schedule',
      showBackButton: true,
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: activeReminders.length,
        itemBuilder: (context, index) {
          final reminder = activeReminders[index];
          final med = medications.firstWhere(
            (m) => m.id == reminder.medicationId,
          );

          // Only consider dose logs scheduled for today
          final isTaken = doseLogs.any(
            (log) =>
                log.reminderId == reminder.id &&
                log.isTaken &&
                log.scheduledAt.isAfter(todayStart) &&
                log.scheduledAt.isBefore(todayEnd),
          );

          // Determine if the reminder time has already passed today
          final parts = reminder.scheduledTime.split(':');
          final remHour = int.tryParse(parts.first) ?? 8;
          final remMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
          final reminderDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            remHour,
            remMinute,
          );
          final isPast = now.isAfter(reminderDateTime);

          // Is it scheduled for today?
          final isScheduledForToday = _dayMatches(reminder.days, todayWeekday, todayWeekdayFull);

          final String status;
          if (isScheduledForToday) {
            if (isTaken) {
              status = 'TAKEN';
            } else if (isPast) {
              status = 'MISSED';
            } else {
              status = 'UPCOMING';
            }
          } else {
            status = 'UPCOMING';
          }

          return McReminderCard(
            medication: med,
            scheduledTime: reminder.scheduledTime,
            status: status,
            onTap: () => Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(
              AppRoutes.doseConfirm,
              arguments: {
                'reminder': reminder,
                'medication': med,
              },
            ),
          );
        },
      ),
    );
  }

  String _weekdayAbbrev(DateTime date) {
    const abbreviations = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return abbreviations[date.weekday - 1];
  }

  String _weekdayFullName(DateTime date) {
    const fullNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return fullNames[date.weekday - 1];
  }

  bool _dayMatches(List<String> days, String abbrev, String fullName) {
    for (final d in days) {
      final normalized = d.trim().toLowerCase();
      if (normalized == abbrev.toLowerCase()) return true;
      if (normalized == fullName.toLowerCase()) return true;
      if (normalized.length >= 3 &&
          fullName.toLowerCase().startsWith(normalized)) {
        return true;
      }
    }
    return false;
  }
}
