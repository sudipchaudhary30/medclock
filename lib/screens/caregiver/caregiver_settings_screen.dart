import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class CaregiverSettingsScreen extends ConsumerStatefulWidget {
  const CaregiverSettingsScreen({super.key});

  @override
  ConsumerState<CaregiverSettingsScreen> createState() =>
      _CaregiverSettingsScreenState();
}

class _CaregiverSettingsScreenState extends ConsumerState<CaregiverSettingsScreen> {
  bool _offlineMode = false;
  String _lastSynced = "2m ago";
  String _quietHours = "10:00 PM - 07:00 AM";

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Styled rounded icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF0F6D95),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F1E24),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9AA7B3),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9AA7B3),
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: CustomScrollView(
        slivers: [
          // Custom premium transparent header matching the patient screens
          SliverAppBar(
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFF4F7FC),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0F1E24), size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Settings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F1E24),
                fontFamily: 'serif',
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.profile),
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF6A7D90),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Preferences Section Title
                  const Text(
                    'APP PREFERENCES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F6D95),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // App Preferences Card Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushNamed(AppRoutes.notificationSettings);
                          },
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16, color: Color(0xFFF1F3F5)),
                        _buildSettingItem(
                          icon: Icons.nights_stay_outlined,
                          title: 'Quiet Hours',
                          subtitle: _quietHours,
                          onTap: () {
                            // Can show dialog or quiet hours picker
                          },
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16, color: Color(0xFFF1F3F5)),
                        _buildSettingItem(
                          icon: Icons.accessibility_new_rounded,
                          title: 'Accessibility',
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushNamed(AppRoutes.accessibilitySettings);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Sync & Offline Section Title
                  const Text(
                    'SYNC & Offline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F6D95),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Sync & Offline Card Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: Icons.sync_rounded,
                          title: 'Sync Devices',
                          subtitle: 'Last synced $_lastSynced',
                          onTap: () {
                            setState(() {
                              _lastSynced = "just now";
                            });
                          },
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16, color: Color(0xFFF1F3F5)),
                        _buildSettingItem(
                          icon: Icons.cloud_queue_rounded,
                          title: 'Offline Mode',
                          onTap: () {},
                          trailing: Switch.adaptive(
                            value: _offlineMode,
                            activeTrackColor: const Color(0xFF0F6D95),
                            onChanged: (val) {
                              setState(() {
                                _offlineMode = val;
                              });
                            },
                          ),
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16, color: Color(0xFFF1F3F5)),
                        _buildSettingItem(
                          icon: Icons.calendar_today_outlined,
                          title: 'Adaptive Reminder',
                          onTap: () {
                            Navigator.of(context, rootNavigator: true)
                                .pushNamed(AppRoutes.adaptiveReminder);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFD93838),
                        size: 18,
                      ),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD93838),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFD1D1), width: 1.2),
                        backgroundColor: const Color(0xFFFFF5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true)
                              .pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Build/Version details footer
                  const Center(
                    child: Text(
                      'Version 2.4.0 (Build 1082)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9AA7B3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
