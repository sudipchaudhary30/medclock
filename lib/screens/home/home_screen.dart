import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../../models/medication_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dose_log_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/layout/mc_bottom_nav.dart';
import '../../widgets/media/mc_pill_image.dart';
import '../../config/app_theme.dart';

const Color _homePageBg = Color(0xFFF4F7FC);
const Color _homeAppBarBlue = Color(0xFF0B3D66);
const Color _homeHeroBlue = Color(0xFF24628C);
const Color _homeHeroBlueDark = Color(0xFF1E567C);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final int _selectedIndex = 0;

  void _onTabTap(int index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.doseHistory);
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.refill);
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final reminders = ref.watch(reminderProvider);
    final medications = ref.watch(medicationProvider);
    final doseLogs = ref.watch(doseLogProvider);
    final streakCount = _calculateStreak(doseLogs);
    final adherenceRate = _calculateAdherenceRate(doseLogs);
    final visibleReminders = reminders.take(2).toList();
    final visibleMedications = medications.take(2).toList();

    return Scaffold(
      backgroundColor: _homePageBg,
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoutes.addMedication),
        backgroundColor: const Color(0xFF0E6B94),
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: McBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onTabTap,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              _TopLogoCard(
                logo: Image.asset(
                  'assets/medclocklogo.png',
                  height: 42,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _HeroCard(
                  userName: user?.name ?? 'Patient',
                  streakCount: streakCount,
                  adherenceRate: adherenceRate,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today',
                      style: AppTheme.heading3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.reminderList),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: _homeHeroBlue,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View Schedule'),
                          SizedBox(width: 2),
                          Icon(Icons.chevron_right_rounded, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: reminders.isEmpty
                    ? _BackendEmptyCard(
                        title: 'No reminders scheduled',
                        subtitle:
                            'Add medications and reminders in the backend to populate this section.',
                        icon: Icons.event_busy_rounded,
                      )
                    : Column(
                        children: visibleReminders.map((reminder) {
                          final med = medications.firstWhere(
                            (m) => m.id == reminder.medicationId,
                            orElse: () => MedicationModel(
                              id: reminder.medicationId,
                              userId: reminder.userId,
                              name: 'Medication',
                              dosage: 'N/A',
                            ),
                          );
                          final isTaken = doseLogs.any(
                            (log) =>
                                log.reminderId == reminder.id && log.isTaken,
                          );

                          return _ReminderCard(
                            medicationName: med.name,
                            dosageLine: '${med.dosage} • ${med.form}',
                            time: _formatReminderTime(reminder.scheduledTime),
                            status: isTaken ? 'TAKEN' : 'UPCOMING',
                            statusColor: isTaken
                                ? const Color(0xFFDBF0F8)
                                : const Color(0xFFE7F3FB),
                            statusTextColor: const Color(0xFF0D6A95),
                            pillPhotoUrl: med.pillPhotoUrl,
                            trailingIcon: isTaken
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.doseConfirm,
                              arguments: {
                                'reminder': reminder,
                                'medication': med,
                              },
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Supply Status',
                  style: AppTheme.heading3.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (medications.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _BackendEmptyCard(
                    title: 'No medications added',
                    subtitle:
                        'Add medications from the backend to show supply cards here.',
                    icon: Icons.medication_rounded,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: visibleMedications.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final med = visibleMedications[index];
                        final percentage = med.totalSupply > 0
                            ? med.currentSupply / med.totalSupply
                            : 0.0;
                        return _SupplyCard(
                          medication: med,
                          percentage: percentage,
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopLogoCard extends StatelessWidget {
  final Widget logo;

  const _TopLogoCard({required this.logo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          logo,
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBFD6E8), width: 1.5),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF6A7D90),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String userName;
  final int streakCount;
  final double adherenceRate;

  const _HeroCard({
    required this.userName,
    required this.streakCount,
    required this.adherenceRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_homeHeroBlue, _homeHeroBlueDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good morning,',
                    style: TextStyle(
                      color: Color(0xFFE8EEF5),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '$streakCount Day Streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Adherence Rate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${adherenceRate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final String medicationName;
  final String dosageLine;
  final String time;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final String? pillPhotoUrl;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const _ReminderCard({
    required this.medicationName,
    required this.dosageLine,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.pillPhotoUrl,
    required this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 62,
                margin: const EdgeInsets.only(right: 9, top: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F6D95),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              McPillImage(imageUrl: pillPhotoUrl, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicationName,
                      style: const TextStyle(
                        color: Color(0xFF0D1E30),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dosageLine,
                      style: const TextStyle(
                        color: Color(0xFF216A97),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF6F7D8E),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E6B94),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(trailingIcon, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupplyCard extends StatelessWidget {
  final MedicationModel medication;
  final double percentage;

  const _SupplyCard({required this.medication, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final daysLeft = medication.currentSupply;
    final isLow = percentage < 0.25;

    return Container(
      width: 152,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: const Color(0xFFE7EEF5),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLow ? const Color(0xFFD92D20) : const Color(0xFF0F6C95),
                  ),
                  strokeWidth: 5,
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF2C5F7C),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                daysLeft.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Color(0xFF6C7A89),
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'DAYS LEFT',
                style: TextStyle(
                  color: Color(0xFF6C7A89),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                medication.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2B3A4B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackendEmptyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _BackendEmptyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0F6D95).withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0F6D95)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0D1E30),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6F7D8E),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

int _calculateStreak(List<dynamic> doseLogs) {
  final takenDates = <DateTime>{};
  for (final log in doseLogs) {
    if (log.isTaken) {
      final date = DateTime(
        log.scheduledAt.year,
        log.scheduledAt.month,
        log.scheduledAt.day,
      );
      takenDates.add(date);
    }
  }

  var streak = 0;
  var cursor = DateTime.now();
  while (true) {
    final date = DateTime(cursor.year, cursor.month, cursor.day);
    if (takenDates.contains(date)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}

double _calculateAdherenceRate(List<dynamic> doseLogs) {
  if (doseLogs.isEmpty) return 0.0;
  final total = doseLogs.length;
  final taken = doseLogs.where((log) => log.isTaken).length;
  return (taken / total) * 100;
}

String _formatReminderTime(String scheduledTime) {
  final parts = scheduledTime.split(':');
  final hour = int.tryParse(parts.first) ?? 8;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  final minuteText = minute.toString().padLeft(2, '0');
  return '$displayHour:$minuteText $period';
}
