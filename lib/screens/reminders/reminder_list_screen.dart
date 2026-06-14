import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/medication_model.dart';
import '../../providers/medication_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/cards/mc_reminder_card.dart';

class ReminderListScreen extends ConsumerWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderProvider);
    final medications = ref.watch(medicationProvider);

    return McScaffold(
      title: 'Reminder Schedule',
      showBackButton: true,
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          final med = medications.firstWhere(
            (m) => m.id == reminder.medicationId,
            orElse: () => MedicationModel(
              id: reminder.medicationId,
              userId: reminder.userId,
              name: 'Medication',
              dosage: 'N/A',
            ),
          );

          return McReminderCard(
            medication: med,
            scheduledTime: reminder.scheduledTime,
            streakCount: reminder.lateCount,
            snoozesRemaining: reminder.maxSnoozeCount - reminder.currentSnoozeCount,
          );
        },
      ),
    );
  }
}
