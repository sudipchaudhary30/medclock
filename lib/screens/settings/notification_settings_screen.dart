import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _globalNotifications = true;

  // Medication Alerts
  bool _doseReminders = true;
  bool _missedDoseAlerts = true;
  bool _refillReminders = false;

  // Caregiver Updates
  bool _patientActivity = true;
  bool _healthReports = false;

  // System
  bool _securityAlerts = true;
  bool _appUpdates = false;

  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F1E24),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9AA7B3),
                  ),
                ),
              ],
            ),
          ),
          // Toggle Switch
          Switch.adaptive(
            value: value,
            activeTrackColor: const Color(0xFF0F6D95),
            onChanged: _globalNotifications ? onChanged : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: CustomScrollView(
        slivers: [
          // Custom Header matching the screenshot
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
              'Notification',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F1E24),
                fontFamily: 'serif',
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCBDCDD), width: 1.5),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=120&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                  // Global Notifications Card
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
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Global Notifications',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F1E24),
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage all MedClock alerts at once',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _globalNotifications,
                          activeTrackColor: const Color(0xFF0F6D95),
                          onChanged: (val) {
                            setState(() {
                              _globalNotifications = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Medication Alerts Section
                  const Text(
                    'MEDICATION ALERTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F6D95),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                        _buildToggleItem(
                          icon: Icons.notifications_none_rounded,
                          iconColor: const Color(0xFF0F6D95),
                          iconBgColor: const Color(0xFFE5EFF2),
                          title: 'Dose Reminders',
                          subtitle: "Receive alerts when it's time for your medication",
                          value: _doseReminders,
                          onChanged: (val) => setState(() => _doseReminders = val),
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16, color: Color(0xFFF1F3F5)),
                        _buildToggleItem(
                          icon: Icons.warning_amber_rounded,
                          iconColor: const Color(0xFFD93838),
                          iconBgColor: const Color(0xFFFFF5F5),
                          title: 'Missed Dose Alerts',
                          subtitle: 'Emergency notifications for skipped medications',
                          value: _missedDoseAlerts,
                          onChanged: (val) => setState(() => _missedDoseAlerts = val),
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16, color: Color(0xFFF1F3F5)),
                        _buildToggleItem(
                          icon: Icons.archive_outlined,
                          iconColor: const Color(0xFF0F6D95),
                          iconBgColor: const Color(0xFFE5EFF2),
                          title: 'Refill Reminders',
                          subtitle: 'Get notified when stock is running low',
                          value: _refillReminders,
                          onChanged: (val) => setState(() => _refillReminders = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Caregiver Updates Section
                  const Text(
                    'CAREGIVER UPDATES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F6D95),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                        _buildToggleItem(
                          icon: Icons.people_outline_rounded,
                          iconColor: const Color(0xFF0F6D95),
                          iconBgColor: const Color(0xFFE5EFF2),
                          title: 'Patient Activity',
                          subtitle: 'Real-time alerts on patient dose status',
                          value: _patientActivity,
                          onChanged: (val) => setState(() => _patientActivity = val),
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16, color: Color(0xFFF1F3F5)),
                        _buildToggleItem(
                          icon: Icons.bar_chart_rounded,
                          iconColor: const Color(0xFF0F6D95),
                          iconBgColor: const Color(0xFFE5EFF2),
                          title: 'Health Reports',
                          subtitle: 'Weekly insights and clinical summaries',
                          value: _healthReports,
                          onChanged: (val) => setState(() => _healthReports = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // System Section
                  const Text(
                    'SYSTEM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F6D95),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                        _buildToggleItem(
                          icon: Icons.shield_outlined,
                          iconColor: const Color(0xFF0F6D95),
                          iconBgColor: const Color(0xFFE5EFF2),
                          title: 'Security Alerts',
                          subtitle: 'Account login and privacy updates',
                          value: _securityAlerts,
                          onChanged: (val) => setState(() => _securityAlerts = val),
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16, color: Color(0xFFF1F3F5)),
                        _buildToggleItem(
                          icon: Icons.system_update_alt_rounded,
                          iconColor: const Color(0xFF0F6D95),
                          iconBgColor: const Color(0xFFE5EFF2),
                          title: 'App Updates',
                          subtitle: 'Notifications about new clinical features',
                          value: _appUpdates,
                          onChanged: (val) => setState(() => _appUpdates = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
