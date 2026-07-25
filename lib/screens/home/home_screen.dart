import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/routes.dart';
import '../../models/medication_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dose_log_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/media/mc_pill_image.dart';
import '../../widgets/cards/mc_reminder_card.dart';
import '../../config/app_theme.dart';

const Color _homePageBg = Color(0xFFEFF4FF);
const Color _homeHeroBlue = Color(0xFF24628C);
const Color _homeHeroBlueDark = Color(0xFF1E567C);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final reminders = ref.watch(reminderProvider);
    final medications = ref.watch(medicationProvider);
    final doseLogs = ref.watch(doseLogProvider);
    final streakCount = _calculateStreak(doseLogs);
    final adherenceRate = _calculateAdherenceRate(doseLogs);
    final now = DateTime.now();
    final todayWeekday = _weekdayAbbrev(now);
    final todayWeekdayFull = _weekdayFullName(now);

    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // Debug: log what we're working with
    debugPrint('[HomeScreen] today weekday: $todayWeekday / $todayWeekdayFull');
    debugPrint('[HomeScreen] reminders count: ${reminders.length}');
    debugPrint('[HomeScreen] doseLogs count: ${doseLogs.length}');
    for (final r in reminders) {
      debugPrint(
        '[HomeScreen] reminder id=${r.id} days=${r.days} time=${r.scheduledTime}',
      );
    }

    final todayScheduleItems = <Map<String, dynamic>>[];
    final todayReminders = reminders.where((r) {
      return medications.any((m) => m.id == r.medicationId);
    }).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    for (final reminder in todayReminders) {
      final med = medications.firstWhere((m) => m.id == reminder.medicationId);

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

      final String status;
      final Color statusColor;
      final Color statusTextColor;
      final IconData trailingIcon;

      if (isTaken) {
        status = 'TAKEN';
        statusColor = const Color(0xFFDBF0F8);
        statusTextColor = const Color(0xFF0D6A95);
        trailingIcon = Icons.check_rounded;
      } else if (isPast) {
        status = 'MISSED';
        statusColor = const Color(0xFFFFF0F0);
        statusTextColor = const Color(0xFFD0363A);
        trailingIcon = Icons.close_rounded;
      } else {
        status = 'UPCOMING';
        statusColor = const Color(0xFFE7F3FB);
        statusTextColor = const Color(0xFF0D6A95);
        trailingIcon = Icons.add_rounded;
      }

      todayScheduleItems.add({
        'reminder': reminder,
        'medication': med,
        'time': _formatReminderTime(reminder.scheduledTime),
        'scheduleLabel': _scheduleLabel(reminder.scheduledTime),
        'status': status,
        'statusColor': statusColor,
        'statusTextColor': statusTextColor,
        'trailingIcon': trailingIcon,
      });
    }

    final visibleScheduleItems = todayScheduleItems.take(2).toList();
    final visibleMedications = medications.toList();

    return Scaffold(
      backgroundColor: _homePageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/medclocklogo.png',
          height: 60,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(AppRoutes.profile),
            icon: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF6A7D90),
            ),
          ),
        ],
        shape: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
            width: 0.8,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(AppRoutes.addMedication),
        backgroundColor: const Color(0xFF0E6B94),
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      // Bottom navigation handled by AppShell
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
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
                        rootNavigator: true,
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
                child: todayScheduleItems.isEmpty
                    ? _BackendEmptyCard(
                        title: 'No reminders scheduled',
                        subtitle:
                            'Add medications and reminders in the backend to populate this section.',
                        icon: Icons.event_busy_rounded,
                      )
                    : Column(
                        children: visibleScheduleItems.map((item) {
                          final reminder = item['reminder'];
                          final med = item['medication'] as MedicationModel;
                          final status = item['status'] as String;

                          return McReminderCard(
                            medication: med,
                            scheduledTime: reminder.scheduledTime,
                            status: status,
                            onTap: () =>
                                Navigator.of(
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
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // Slightly increased aspect ratio to prevent minor pixel overflow
                    childAspectRatio: 0.80,
                    children: visibleMedications.map((med) {
                      return _SupplyCard(medication: med);
                    }).toList(),
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

class _SupplyCard extends ConsumerWidget {
  final MedicationModel medication;

  const _SupplyCard({required this.medication});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysLeft = medication.currentSupply;
    final isLow = medication.currentSupply <= medication.refillThreshold;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8EFF5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: SizedBox(
                  height: 110,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: McPillImage(
                      imageUrl: medication.pillPhotoUrl,
                      size: 110,
                      fitToParentWidth: true,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF152B40),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medication.dosage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5C7283),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isLow
                                ? const Color(0xFFFFF1F1)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            isLow ? 'Refill' : 'Active',
                            style: TextStyle(
                              color: isLow
                                  ? const Color(0xFFD0363A)
                                  : const Color(0xFF1E5D8A),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$daysLeft days left',
                              style: const TextStyle(
                                color: Color(0xFF1F3D5B),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              medication.totalSupply > 0
                                  ? '${medication.currentSupply}/${medication.totalSupply}'
                                  : 'No stock info',
                              style: const TextStyle(
                                color: Color(0xFF667887),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            child: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed(AppRoutes.addMedication, arguments: medication);
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete medication'),
                      content: const Text(
                        'Are you sure you want to delete this medication?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    final success = await ref
                        .read(medicationProvider.notifier)
                        .deleteMedication(medication.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Medication deleted')),
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              icon: const Icon(
                Icons.more_vert,
                size: 20,
                color: Color(0xFF6F7D8E),
              ),
            ),
          ),
        ),
      ],
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
  final dateTime = DateTime(2000, 1, 1, hour, minute);
  return DateFormat('hh:mm a').format(dateTime);
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

String _scheduleLabel(String scheduledTime) {
  final hour = int.tryParse(scheduledTime.split(':').first) ?? 8;
  if (hour < 10) return 'Before Breakfast';
  if (hour < 12) return 'After Breakfast';
  if (hour < 14) return 'Before Lunch';
  if (hour < 17) return 'After Lunch';
  if (hour < 20) return 'Before Dinner';
  return 'After Dinner';
}
