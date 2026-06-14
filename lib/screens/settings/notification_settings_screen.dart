import 'package:flutter/material.dart';
import '../../widgets/layout/mc_scaffold.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _remindersEnabled = true;
  bool _caregiverSync = true;

  @override
  Widget build(BuildContext context) {
    return McScaffold(
      title: 'Notifications',
      showBackButton: true,
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Enable Reminders'),
            subtitle: const Text('Receive push alerts for scheduled doses.'),
            value: _remindersEnabled,
            onChanged: (val) => setState(() => _remindersEnabled = val),
          ),
          SwitchListTile.adaptive(
            title: const Text('Caregiver Alert Sync'),
            subtitle: const Text('Forward medication compliance records immediately.'),
            value: _caregiverSync,
            onChanged: (val) => setState(() => _caregiverSync = val),
          ),
        ],
      ),
    );
  }
}
