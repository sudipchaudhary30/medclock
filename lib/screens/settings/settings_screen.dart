import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';

import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/buttons/mc_primary_button.dart';
import '../../services/sync_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _dailyReminders = true;
  bool _refillAlerts = true;
  bool _offlineMode = false;
  String _lastSynced = 'Never';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final local = ref.read(localStorageServiceProvider);
      final box = local.getBox(AppConstants.settingsBox);
      setState(() {
        _dailyReminders = box.get('dailyReminders', defaultValue: true) as bool;
        _refillAlerts = box.get('refillAlerts', defaultValue: true) as bool;
        _offlineMode = box.get('offlineMode', defaultValue: false) as bool;
        final last = box.get('lastSync') as String?;
        _lastSynced = last ?? 'Never';
      });
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final local = ref.read(localStorageServiceProvider);
    final box = local.getBox(AppConstants.settingsBox);
    await box.put(key, value);
  }

  Future<void> _performSync() async {
    final api = ref.read(apiServiceProvider);
    final local = ref.read(localStorageServiceProvider);
    final syncService = SyncService(api, local);
    try {
      await syncService.syncOfflineData();
      final now = DateTime.now().toIso8601String();
      await _saveSetting('lastSync', now);
      setState(() {
        _lastSynced = now;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sync completed')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sync failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return McScaffold(
      title: 'Settings',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Info Header
            // Use GestureDetector so the header itself does not receive focus;
            // Tab should land on the edit IconButton instead.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.profile),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        (user?.name ?? 'Animesh').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Animesh Prasad',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Patient ID: MC-8829-NP',
                            style: AppTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    Focus(
                      onKey: (FocusNode node, RawKeyEvent event) {
                        if (event is RawKeyDownEvent) {
                          final key = event.logicalKey;
                          if (key == LogicalKeyboardKey.enter ||
                              key == LogicalKeyboardKey.space) {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(AppRoutes.editProfile);
                            return KeyEventResult.handled;
                          }
                        }
                        return KeyEventResult.ignored;
                      },
                      child: Semantics(
                        label: 'Edit profile',
                        button: true,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          tooltip: 'Edit profile',
                          onPressed: () => Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(AppRoutes.editProfile),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notifications Card Section
            Text(
              'NOTIFICATIONS',
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Daily Reminders'),
                    subtitle: const Text('Pills and dose schedules'),
                    value: _dailyReminders,
                    activeTrackColor: AppTheme.primaryColor,
                    onChanged: (val) async {
                      setState(() => _dailyReminders = val);
                      await _saveSetting('dailyReminders', val);
                      // update in-memory user settings if present
                      final user = ref.read(authProvider);
                      if (user != null) {
                        final newSettings = user.settings.copyWith();
                        ref
                            .read(authProvider.notifier)
                            .updateSettings(newSettings);
                      }
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: const Text('Refill Alerts'),
                    subtitle: const Text('Notify when medicine is low'),
                    value: _refillAlerts,
                    activeTrackColor: AppTheme.primaryColor,
                    onChanged: (val) async {
                      setState(() => _refillAlerts = val);
                      await _saveSetting('refillAlerts', val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Care Circle Card Section
            Text(
              'CARE CIRCLE',
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.familyDashboard),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.teal.shade100,
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Niruta Prasad',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Primary Caregiver',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(AppRoutes.familyDashboard),
                          child: const Text('Manage'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(context, rootNavigator: true)
                          .pushNamed(AppRoutes.qrLink),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.qr_code_2_rounded,
                              color: AppTheme.primaryColor,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Link Caregiver',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryDark,
                                    ),
                                  ),
                                  Text(
                                    'Generate sync code for family',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.addMember),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Family Member'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppTheme.dividerColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Preference list items
            Text(
              'APP PREFERENCES',
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.sync_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text('Sync Devices'),
                    subtitle: Text('Last synced: $_lastSynced'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _performSync,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(
                      Icons.wifi_off_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text('Offline Mode'),
                    trailing: Switch(
                      value: _offlineMode,
                      activeThumbColor: AppTheme.primaryColor,
                      onChanged: (val) async {
                        setState(() => _offlineMode = val);
                        await _saveSetting('offlineMode', val);
                      },
                    ),
                    onTap: () async {
                      setState(() => _offlineMode = !_offlineMode);
                      await _saveSetting('offlineMode', _offlineMode);
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(
                      Icons.accessibility_new_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text('Accessibility'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(AppRoutes.accessibilitySettings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Log Out Button
            McPrimaryButton(
              label: 'Sign Out',
              backgroundColor: Colors.red.shade50.withValues(alpha: 0.9),
              textColor: Colors.red,
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
