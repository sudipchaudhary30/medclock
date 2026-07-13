import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medclock/models/dose_log_model.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/family_member_model.dart';
import '../../models/medication_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dose_log_provider.dart';
import '../../providers/family_provider.dart';
import '../../providers/medication_provider.dart';

class CaregiverDashboard extends ConsumerStatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  ConsumerState<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends ConsumerState<CaregiverDashboard> {
  @override
  Widget build(BuildContext context) {
    final familyGroup = ref.watch(familyProvider);
    final doseLogs = ref.watch(doseLogProvider);
    final medications = ref.watch(medicationProvider);
    final patients =
        familyGroup?.members
            .where((member) => member.role == 'patient')
            .toList() ??
        [];
    final isConnected = patients.isNotEmpty;

    List<Map<String, dynamic>> buildPatientCards() {
      return patients.map((member) {
        final patientLogs = doseLogs
            .where(
              (log) =>
                  log.familyMemberId == member.id ||
                  log.familyMemberId == member.userId,
            )
            .toList();

        patientLogs.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
        final total = patientLogs.length;
        final takenCount = patientLogs.where((log) => log.isTaken).length;
        final missedCount = patientLogs.where((log) => log.isMissed).length;
        final bool hasHistory = total > 0;
        final int adherence = hasHistory
            ? ((takenCount / total) * 100).round()
            : 0;

        final Map<String, Object> latestStatus = hasHistory
            ? _buildLatestStatus(patientLogs.first, missedCount)
            : {
                'text': 'No reported doses',
                'color': AppTheme.textSecondary,
                'icon': Icons.info_outline_rounded,
              };

        return {
          'name': member.name,
          'initials': member.initials,
          'avatarColor': member.color,
          'adherence': adherence,
          'statusText': latestStatus['text'] as String,
          'statusColor': latestStatus['color'] as Color,
          'statusIcon': latestStatus['icon'] as IconData,
          'recentLogs': patientLogs,
        };
      }).toList();
    }

    final List<Map<String, dynamic>> patientCards = buildPatientCards();

    final List<Map<String, dynamic>> alertLog;
    if (doseLogs.isEmpty) {
      alertLog = [
        {
          'time': '--',
          'dotColor': const Color(0xFF6A7D90),
          'text': 'No recent patient events available yet.',
          'highlight': 'patient',
        },
      ];
    } else {
      final recentDoseLogs = doseLogs
          .where((log) => log.familyMemberId != null)
          .toList();
      recentDoseLogs.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      alertLog = recentDoseLogs.take(3).map((log) {
        final patient = patients.firstWhere(
          (member) =>
              member.id == log.familyMemberId ||
              member.userId == log.familyMemberId,
          orElse: () => FamilyMemberModel(
            id: log.familyMemberId ?? '',
            userId: '',
            name: 'Patient',
            colorHex: '#2D7DD2',
          ),
        );
        final medication = medications.firstWhere(
          (med) => med.id == log.medicationId,
          orElse: () => MedicationModel(
            id: log.medicationId,
            userId: '',
            name: 'Medication',
            dosage: '',
            form: 'tablet',
            instructions: '',
          ),
        );
        final eventText = log.isTaken
            ? 'confirmed ${medication.name}'
            : log.isMissed
            ? 'missed ${medication.name}'
            : 'skipped ${medication.name}';
        final formattedTime = TimeOfDay.fromDateTime(
          log.scheduledAt,
        ).format(context);
        return {
          'time': formattedTime,
          'dotColor': log.isTaken ? AppTheme.successColor : AppTheme.errorColor,
          'text': '${patient.name} $eventText',
          'highlight': patient.name,
        };
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/medclocklogo.png',
          height: 60,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'MedClock',
                style: AppTheme.heading3.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(authProvider);
              final photoBase64 = user?.photoBase64;
              return IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.profile),
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryLight,
                  foregroundImage: photoBase64 != null && photoBase64.isNotEmpty
                      ? MemoryImage(base64Decode(photoBase64))
                      : null,
                  child: photoBase64 == null || photoBase64.isEmpty
                      ? const Icon(
                          Icons.person_outline_rounded,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                ),
              );
            },
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
        child: CustomScrollView(
          slivers: [
            if (!isConnected)
              // Empty state when no patients are linked yet
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: AppTheme.primaryColor,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Patients Linked',
                          textAlign: TextAlign.center,
                          style: AppTheme.heading3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap the scanner button below to scan a patient\'s invitation QR code and begin monitoring compliance.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // Redesigned Connected Dashboard View
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + LIVE Badge row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Caregiver Dashboard',
                                  style: AppTheme.heading2.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Monitoring ${patients.length} active patients',
                                  style: AppTheme.caption.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // LIVE badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'LIVE',
                                  style: AppTheme.caption.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.successColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Patient Cards
                      ...patientCards.map((patient) {
                        final int adherence = patient['adherence'] as int;
                        final Color statusColor =
                            patient['statusColor'] as Color;
                        final Color ringColor = adherence >= 80
                            ? AppTheme.successColor
                            : AppTheme.errorColor;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Row(
                              children: [
                                // Left accent border indicator
                                Container(
                                  width: 4,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Rounded Avatar
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: patient['avatarColor'] as Color,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    patient['initials'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Name & compliance status
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patient['name'] as String,
                                        style: AppTheme.heading3.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            patient['statusIcon'] as IconData,
                                            size: 14,
                                            color: statusColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            patient['statusText'] as String,
                                            style: AppTheme.bodySmall.copyWith(
                                              color: statusColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Custom Adherence circular progress ring
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ringColor.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: ringColor,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$adherence%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: ringColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Alert Log section header
                      Text(
                        'Alert Log',
                        style: AppTheme.heading3.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Alert timeline items
                      ...alertLog.map((alert) {
                        final String fullText = alert['text'] as String;
                        final String highlight = alert['highlight'] as String;
                        final int highlightStart = fullText.indexOf(highlight);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline vertical indicator
                              Column(
                                children: [
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: alert['dotColor'] as Color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 1.5,
                                    height: 48,
                                    color: AppTheme.dividerColor,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),

                              // Text content in a light blue container box
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alert['time'] as String,
                                      style: AppTheme.caption.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          style: AppTheme.bodySmall.copyWith(
                                            color: AppTheme.textPrimary,
                                            height: 1.3,
                                          ),
                                          children: highlightStart >= 0
                                              ? [
                                                  if (highlightStart > 0)
                                                    TextSpan(
                                                      text: fullText.substring(
                                                        0,
                                                        highlightStart,
                                                      ),
                                                    ),
                                                  TextSpan(
                                                    text: highlight,
                                                    style: AppTheme.bodySmall
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppTheme
                                                              .textPrimary,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text: fullText.substring(
                                                      highlightStart +
                                                          highlight.length,
                                                    ),
                                                  ),
                                                ]
                                              : [TextSpan(text: fullText)],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),

      // Scanner floating action button styled like the mockup (blue scanner circle)
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.qrScanner),
          backgroundColor: AppTheme.primaryColor,
          elevation: 10,
          highlightElevation: 6,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Map<String, Object> _buildLatestStatus(DoseLogModel log, int missedCount) {
    if (log.isTaken) {
      return {
        'text': missedCount == 0 ? 'All doses taken' : 'Last dose taken',
        'color': AppTheme.successColor,
        'icon': Icons.check_circle_outline_rounded,
      };
    }

    if (log.isMissed) {
      return {
        'text': missedCount == 1
            ? '1 dose missed'
            : '$missedCount doses missed',
        'color': AppTheme.errorColor,
        'icon': Icons.error_outline_rounded,
      };
    }

    return {
      'text': 'Last dose skipped',
      'color': AppTheme.warningColor,
      'icon': Icons.info_outline_rounded,
    };
  }
}
