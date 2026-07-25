import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_theme.dart';
import '../../models/medication_model.dart';
import '../../models/reminder_model.dart';
import '../../models/dose_log_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dose_log_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/inputs/mc_dropdown.dart';
import '../../widgets/inputs/mc_text_field.dart';
import '../../widgets/buttons/mc_primary_button.dart';
import '../../widgets/common/mc_toast.dart';

class MissedDoseScreen extends ConsumerStatefulWidget {
  const MissedDoseScreen({super.key});

  @override
  ConsumerState<MissedDoseScreen> createState() => _MissedDoseScreenState();
}

class _MissedDoseScreenState extends ConsumerState<MissedDoseScreen> {
  MissedReason _selectedReason = MissedReason.forgot;
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ReminderModel reminder = args['reminder'];
    final MedicationModel medication = args['medication'];
    final user = ref.read(authProvider);

    setState(() => _isLoading = true);

    final log = DoseLogModel(
      id: const Uuid().v4(),
      userId: user?.id ?? '',
      medicationId: medication.id,
      reminderId: reminder.id,
      status: DoseStatus.missed,
      scheduledAt: DateTime.now(),
      missedReason: _selectedReason,
      missedNote: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );

    final success = await ref.read(doseLogProvider.notifier).logDose(log);
    setState(() => _isLoading = false);

    if (success && mounted) {
      McToast.showSuccess(context, 'Dose marked as missed.');
      Navigator.of(context).pop();
    } else if (mounted) {
      McToast.showError(context, 'Failed to update dose log.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return McScaffold(
      title: 'Mark as Missed',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Why was this dose missed?',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Recording a reason helps your physician structure custom medication cycles.',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            McDropdown<MissedReason>(
              label: 'Reason',
              value: _selectedReason,
              items: const [
                DropdownMenuItem(value: MissedReason.forgot, child: Text('Forgot')),
                DropdownMenuItem(value: MissedReason.asleep, child: Text('Asleep')),
                DropdownMenuItem(value: MissedReason.sideEffect, child: Text('Side effect')),
                DropdownMenuItem(value: MissedReason.other, child: Text('Other')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedReason = val);
              },
            ),
            const SizedBox(height: 16),
            McTextField(
              label: 'Additional Note (Optional)',
              hint: 'Describe side effects or alternative causes',
              controller: _noteController,
              maxLines: 3,
            ),
            const Spacer(),
            McPrimaryButton(
              label: 'Save Reason',
              isLoading: _isLoading,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
