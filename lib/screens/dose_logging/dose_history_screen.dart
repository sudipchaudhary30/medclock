import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/routes.dart';
import '../../models/medication_model.dart';
import '../../models/dose_log_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dose_log_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/reminder_provider.dart';

class DoseHistoryScreen extends ConsumerStatefulWidget {
  const DoseHistoryScreen({super.key});

  @override
  ConsumerState<DoseHistoryScreen> createState() => _DoseHistoryScreenState();
}

class _DoseHistoryScreenState extends ConsumerState<DoseHistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  List<DateTime> _buildWeekDays(DateTime centerDate) {
    final weekday = centerDate.weekday;
    final monday = centerDate.subtract(Duration(days: weekday - 1));
    return List.generate(6, (index) => monday.add(Duration(days: index)));
  }

  String _weekdayAbbrev(DateTime date) {
    return DateFormat('E').format(date);
  }

  String _weekdayFullName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  bool _dayMatches(dynamic days, String abbrev, String fullName) {
    if (days is Iterable) {
      return days.contains(abbrev) || days.contains(fullName);
    }
    if (days is String) {
      return days == abbrev || days == fullName;
    }
    return false;
  }

  void _showLogReasonDialog(
    BuildContext context,
    WidgetRef ref,
    String medId,
    DateTime scheduledTime,
    String medName,
  ) {
    final textController = TextEditingController();
    final user = ref.read(authProvider);
    final bool isMock = medId.startsWith('mock-');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Reason for $medName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter the reason why you missed this dose:',
              style: TextStyle(fontSize: 13, color: Color(0xFF536A73)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'e.g. Forgot, fell asleep, side effects...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9AA7B3),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              if (isMock) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reason logged: "${textController.text}"'),
                    backgroundColor: const Color(0xFF0F6D95),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              final newLog = DoseLogModel(
                id: UniqueKey().toString(),
                userId: user?.id ?? 'user-id',
                medicationId: medId,
                status: DoseStatus.missed,
                scheduledAt: scheduledTime,
                missedNote: textController.text,
                missedReason: MissedReason.forgot,
                confirmedAt: DateTime.now(),
              );

              final success = await ref
                  .read(doseLogProvider.notifier)
                  .logDose(newLog);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Dose logged as missed with reason!'
                          : 'Failed to log missed dose.',
                    ),
                    backgroundColor: const Color(0xFF0F6D95),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E6B94),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDose(
    BuildContext context,
    WidgetRef ref,
    String medId,
    DateTime scheduledTime,
    String medName,
  ) async {
    final user = ref.read(authProvider);
    final bool isMock = medId.startsWith('mock-');

    if (isMock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dose logged successfully for $medName!'),
          backgroundColor: const Color(0xFF0F6D95),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newLog = DoseLogModel(
      id: UniqueKey().toString(),
      userId: user?.id ?? 'user-id',
      medicationId: medId,
      status: DoseStatus.taken,
      scheduledAt: scheduledTime,
      confirmedAt: DateTime.now(),
    );

    final success = await ref.read(doseLogProvider.notifier).logDose(newLog);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Dose confirmed successfully!'
                : 'Failed to confirm dose. Please try again.',
          ),
          backgroundColor: const Color(0xFF0F6D95),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(doseLogProvider);
    final medications = ref.watch(medicationProvider);
    final reminders = ref.watch(reminderProvider);

    // Calculate dynamic stats from actual dose logs
    final int totalLogs = logs.length;
    final int onTimeCount = logs.where((l) => l.isTaken).length;
    final int missedCount = logs.where((l) => l.isMissed).length;
    final int adherenceRate = totalLogs == 0
        ? 0
        : ((onTimeCount / totalLogs) * 100).round();

    // Dynamically calculate trend progress (recent 7 days vs overall)
    double trend = 0;
    if (totalLogs > 0) {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final recentLogs = logs
          .where((l) => l.scheduledAt.isAfter(sevenDaysAgo))
          .toList();
      if (recentLogs.isNotEmpty) {
        final recentOnTime = recentLogs.where((l) => l.isTaken).length;
        final recentRate = (recentOnTime / recentLogs.length) * 100;
        trend = recentRate - adherenceRate;
      }
    }
    final String trendString = trend >= 0
        ? '+${trend.round()}%'
        : '${trend.round()}%';

    final weekDays = _buildWeekDays(_selectedDate);
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedDate);
    final String weekdayStr = _weekdayAbbrev(_selectedDate); // e.g. "Wed"

    // Construct schedule items for the selected day from backend database
    final List<Map<String, dynamic>> scheduleItems = [];

    // Find reminders scheduled for the selected weekday
    final dayReminders = reminders.where((r) {
      return _dayMatches(r.days, weekdayStr, _weekdayFullName(_selectedDate));
    }).toList();

    // Sort chronological
    dayReminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    for (var reminder in dayReminders) {
      final med = medications.firstWhere(
        (m) => m.id == reminder.medicationId,
        orElse: () => MedicationModel(
          id: reminder.medicationId,
          userId: reminder.userId,
          name: 'Medication',
          dosage: 'N/A',
        ),
      );

      // Find dose logs matching this day/medication
      final dateLogs = logs
          .where(
            (l) =>
                l.medicationId == reminder.medicationId &&
                l.scheduledAt.year == _selectedDate.year &&
                l.scheduledAt.month == _selectedDate.month &&
                l.scheduledAt.day == _selectedDate.day,
          )
          .toList();

      final DoseLogModel? matchingLog = dateLogs.isNotEmpty
          ? dateLogs.first
          : null;

      String statusStr = 'pending';
      String? noteText;
      if (matchingLog != null) {
        statusStr = matchingLog.status.name;
        if (matchingLog.isTaken) {
          noteText = matchingLog.missedNote ?? 'TAKEN';
        } else if (matchingLog.isMissed) {
          noteText = matchingLog.missedNote;
        }
      }

      final parts = reminder.scheduledTime.split(':');
      final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 8 : 8;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );

      final tempDate = DateTime(2000, 1, 1, hour, minute);
      final formattedTime = DateFormat('h:mm a').format(tempDate);

      scheduleItems.add({
        'id': reminder.id,
        'medicationId': reminder.medicationId,
        'medicationName': med.name,
        'dosageLine':
            '${med.dosage} • ${med.form == 'tablet' ? 'Daily Tablet' : med.form}',
        'timeStr': formattedTime,
        'status': statusStr,
        'note': noteText,
        'scheduledAt': scheduledDateTime,
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
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
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Screen Header
              const Text(
                'Medication History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F1E24),
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tracking your progress toward clinical recovery.',
                style: TextStyle(fontSize: 14, color: Color(0xFF536A73)),
              ),
              const SizedBox(height: 20),

              // Adherence Stats Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
                            'MONTHLY ADHERENCE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F6D95),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$adherenceRate%',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F1E24),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '${trend >= 0 ? "📈" : "📉"} $trendString',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0F6D95),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Circular Progress gauge
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: adherenceRate / 100.0,
                            strokeWidth: 6,
                            backgroundColor: const Color(0xFFE5EFF2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0F6D95),
                            ),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF0F6D95),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // On Time & Missed Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'On Time',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF536A73),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$onTimeCount Doses',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F1E24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Missed',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF536A73),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$missedCount Doses',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calendar Selector Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3D66),
                      fontFamily: 'serif',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime.now();
                      });
                    },
                    child: Row(
                      children: const [
                        Text(
                          'Today ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0F6D95),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                          color: Color(0xFF0F6D95),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calendar Weekdays Slider
              Row(
                children: weekDays.map((date) {
                  final bool isSelected =
                      date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;

                  return _DayChip(
                    date: date,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Timeline Schedule items list
              if (scheduleItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No medications scheduled',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F1E24),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You don\'t have any medications scheduled for this day of the week.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF536A73),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...scheduleItems.map((item) {
                  return _buildTimelineItem(
                    context,
                    medicationName: item['medicationName'],
                    dosageLine: item['dosageLine'],
                    timeStr: item['timeStr'],
                    status: item['status'],
                    note: item['note'],
                    onConfirm: () => _confirmDose(
                      context,
                      ref,
                      item['medicationId'],
                      item['scheduledAt'],
                      item['medicationName'],
                    ),
                    onLogReason: () => _showLogReasonDialog(
                      context,
                      ref,
                      item['medicationId'],
                      item['scheduledAt'],
                      item['medicationName'],
                    ),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String medicationName,
    required String dosageLine,
    required String timeStr,
    required String status, // 'taken', 'missed', 'pending'
    required String? note,
    required VoidCallback onConfirm,
    required VoidCallback onLogReason,
  }) {
    final bool isTaken = status == 'taken';
    final bool isMissed = status == 'missed';
    final bool isPending = status == 'pending';

    final Color markerColor = isTaken
        ? const Color(0xFF0F6D95)
        : isMissed
        ? const Color(0xFFFF6B6B)
        : const Color(0xFF9AA7B3);

    final Color badgeBgColor = isTaken
        ? const Color(0xFFE6F3F7)
        : isMissed
        ? const Color(0xFFFDECEB)
        : Colors.white.withValues(alpha: 0.15);

    final Color badgeTextColor = isTaken
        ? const Color(0xFF0F6D95)
        : isMissed
        ? const Color(0xFFFF6B6B)
        : Colors.white;

    final IconData markerIcon = isTaken
        ? Icons.check_circle_outline_rounded
        : isMissed
        ? Icons.cancel_outlined
        : Icons.access_time_rounded;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Timeline Bar & Marker
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(width: 1.5, color: const Color(0xFFE5EFF2)),
                Positioned(
                  top: 4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF4FF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isTaken
                              ? const Color(0xFFE6F3F7)
                              : isMissed
                              ? const Color(0xFFFDECEB)
                              : const Color(0xFFE5EFF2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(markerIcon, size: 16, color: markerColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isPending ? const Color(0xFF075E84) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isPending
                      ? null
                      : Border(
                          left: BorderSide(
                            color: isTaken
                                ? const Color(0xFF0F6D95)
                                : const Color(0xFFFF6B6B),
                            width: 4,
                          ),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            medicationName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isPending
                                  ? Colors.white
                                  : const Color(0xFF0F1E24),
                              fontFamily: 'serif',
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            timeStr,
                            style: TextStyle(
                              color: badgeTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dosageLine,
                      style: TextStyle(
                        fontSize: 13,
                        color: isPending
                            ? Colors.white.withValues(alpha: 0.8)
                            : const Color(0xFF6A7D90),
                      ),
                    ),
                    if (isTaken && note != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.restaurant_rounded,
                            size: 16,
                            color: Color(0xFF6A7D90),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            note,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF536A73),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ] else if (isMissed) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: onLogReason,
                        child: Row(
                          children: const [
                            Text(
                              'Log reason',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF0F6D95),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Color(0xFF0F6D95),
                            ),
                          ],
                        ),
                      ),
                    ] else if (isPending) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onConfirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF075E84),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Confirm Dose',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Additional options...'),
                                ),
                              );
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.more_horiz_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final weekdayLabel = DateFormat('E').format(date).toUpperCase();
    final dayLabel = DateFormat('d').format(date);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0F6D95)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weekdayLabel,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF536A73),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayLabel,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0F1E24),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0F6D95)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
