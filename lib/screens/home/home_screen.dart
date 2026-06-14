import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/user_model.dart';
import '../../models/medication_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medication_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/layout/mc_section_header.dart';
import '../../widgets/cards/mc_reminder_card.dart';

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
      Navigator.of(context).pushReplacementNamed(AppRoutes.medicationList);
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.doseHistory);
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final reminders = ref.watch(reminderProvider);
    final medications = ref.watch(medicationProvider);

    return McScaffold(
      title: 'Home',
      selectedIndex: _selectedIndex,
      onTabTap: _onTabTap,
      isCaregiver: user?.role == UserRole.caregiver,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome & Streak Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning,',
                        style: AppTheme.bodySmall.copyWith(fontSize: 14),
                      ),
                      Text(
                        user?.name ?? 'Animesh',
                        style: AppTheme.heading2.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Streak Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '12 Day Streak',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Adherence Rate Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Adherence Rate',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.94,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    '94%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Today's Schedule Header
            McSectionHeader(
              title: 'Today\'s Schedule',
              actionLabel: 'View Schedule',
              onAction: () => Navigator.of(context).pushNamed(AppRoutes.reminderList),
            ),

            // Reminder Items list
            if (reminders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: const Center(
                    child: Text('No medications scheduled for today.'),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  final med = medications.firstWhere(
                    (m) => m.id == reminder.medicationId,
                    orElse: () => MedicationModel(
                      id: reminder.medicationId,
                      userId: reminder.userId,
                      name: 'Medication',
                      dosage: 'N/A',
                    ),
                  );

                  return McReminderCard(
                    medication: med,
                    scheduledTime: reminder.scheduledTime,
                    streakCount: reminder.lateCount,
                    snoozesRemaining: reminder.maxSnoozeCount - reminder.currentSnoozeCount,
                    onConfirm: () => Navigator.of(context).pushNamed(
                      AppRoutes.doseConfirm,
                      arguments: {
                        'reminder': reminder,
                        'medication': med,
                      },
                    ),
                    onSnooze: () {
                      ref.read(reminderProvider.notifier).snoozeReminder(reminder.id);
                    },
                    onCamera: () => Navigator.of(context).pushNamed(
                      AppRoutes.doseConfirm,
                      arguments: {
                        'reminder': reminder,
                        'medication': med,
                        'autoCamera': true,
                      },
                    ),
                    onMissed: () => Navigator.of(context).pushNamed(
                      AppRoutes.missedDose,
                      arguments: {
                        'reminder': reminder,
                        'medication': med,
                      },
                    ),
                  );
                },
              ),

            // Supply Status Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                'Supply Status',
                style: AppTheme.heading3.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            // Supply Status Row
            if (medications.isEmpty)
              const SizedBox.shrink()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: medications.map((med) {
                      final percentage = med.totalSupply > 0 
                          ? med.currentSupply / med.totalSupply 
                          : 0.0;
                      final daysLeft = med.currentSupply;
                      
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12.0, bottom: 16.0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: Stack(
                                children: [
                                  Center(
                                    child: CircularProgressIndicator(
                                      value: percentage,
                                      backgroundColor: AppTheme.dividerColor,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        percentage < 0.2 ? Colors.red : AppTheme.primaryColor,
                                      ),
                                      strokeWidth: 6,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      '${(percentage * 100).toInt()}%',
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              daysLeft.toString().padLeft(2, '0'),
                              style: TextStyle(
                                color: percentage < 0.2 ? Colors.red : AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'DAYS LEFT',
                              style: AppTheme.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              med.name,
                              style: AppTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
