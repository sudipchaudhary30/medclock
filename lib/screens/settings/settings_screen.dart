import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/buttons/mc_primary_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final int _selectedIndex = 3;

  void _onTabTap(int index) {
    if (index == 3) return;
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.medicationList);
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.doseHistory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return McScaffold(
      title: 'Settings',
      selectedIndex: _selectedIndex,
      onTabTap: _onTabTap,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Info Header
            Container(
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
                        Text('Patient ID: MC-8829-NP', style: AppTheme.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.profile),
                  ),
                ],
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
                    value: true,
                    activeTrackColor: AppTheme.primaryColor,
                    onChanged: (val) {},
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: const Text('Refill Alerts'),
                    subtitle: const Text('Notify when medicine is low'),
                    value: true,
                    activeTrackColor: AppTheme.primaryColor,
                    onChanged: (val) {},
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
            Container(
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
                      TextButton(onPressed: () {}, child: const Text('Manage')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
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
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
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
                    subtitle: const Text('Last synced 2m ago'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(
                      Icons.wifi_off_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text('Offline Mode'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
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
