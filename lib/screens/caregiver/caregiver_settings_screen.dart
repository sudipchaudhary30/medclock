import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/inputs/mc_text_field.dart';
import '../../widgets/buttons/mc_primary_button.dart';
import '../../widgets/common/mc_toast.dart';

class CaregiverSettingsScreen extends StatefulWidget {
  const CaregiverSettingsScreen({super.key});

  @override
  State<CaregiverSettingsScreen> createState() => _CaregiverSettingsScreenState();
}

class _CaregiverSettingsScreenState extends State<CaregiverSettingsScreen> {
  final _startController = TextEditingController(text: '23:00');
  final _endController = TextEditingController(text: '07:00');
  bool _muteAlerts = false;

  void _save() {
    McToast.showSuccess(context, 'Caregiver settings saved successfully.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return McScaffold(
      title: 'Caregiver Alerts',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quiet Hours', style: AppTheme.heading2),
            const SizedBox(height: 8),
            Text(
              'Specify hours during which non-urgent caregiver alerts will be queued and sent at the end of the period.',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: McTextField(
                    label: 'Quiet Hours Start',
                    controller: _startController,
                    hint: '23:00',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: McTextField(
                    label: 'Quiet Hours End',
                    controller: _endController,
                    hint: '07:00',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile.adaptive(
              title: const Text('Mute Non-Urgent Alerts'),
              subtitle: const Text('Only receive critical warnings like missed dosage windows.'),
              value: _muteAlerts,
              onChanged: (val) => setState(() => _muteAlerts = val),
            ),
            const Spacer(),
            McPrimaryButton(
              label: 'Save Configuration',
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }
}
