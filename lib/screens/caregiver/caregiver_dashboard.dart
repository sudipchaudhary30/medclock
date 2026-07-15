import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medclock/models/dose_log_model.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/family_member_model.dart';
import '../../models/medication_model.dart';
import '../../providers/adherence_provider.dart';
import '../../providers/dose_log_provider.dart';
import '../../providers/family_provider.dart';
import '../../providers/medication_provider.dart';
import 'qr_scanner_screen.dart';

class CaregiverDashboard extends ConsumerStatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  ConsumerState<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends ConsumerState<CaregiverDashboard> {
  /// Builds the adherence percentage ring displayed on each patient card.
  ///
  /// [isLocal] is `true` when the value was computed locally (backend
  /// unreachable), signalled visually with a slightly muted opacity.
  Widget _adherenceCircle(int percent, Color color, {bool isLocal = false}) {
    return Opacity(
      opacity: isLocal ? 0.75 : 1.0,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: color, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          '$percent%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

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
        // Local fallback adherence — used while the async provider loads
        // or when the backend is unreachable.
        final int localAdherence = hasHistory
            ? ((takenCount / total) * 100).round()
            : 0;

        final Map<String, Object> latestStatus = hasHistory
            ? _buildLatestStatus(context, patientLogs.first, missedCount)
            : {
                'text': 'No reported doses',
                'color': AppTheme.textSecondary,
                'icon': Icons.info_outline_rounded,
              };

        return {
          'member': member,
          'name': member.name,
          'initials': member.initials,
          'avatarColor': member.color,
          'localAdherence': localAdherence,
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
          'dotColor': log.isTaken ? const Color(0xFF00A3C4) : AppTheme.errorColor,
          'text': '${patient.name} $eventText',
          'highlight': patient.name,
        };
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                      const SizedBox(height: 16),
                      Text(
                        'Caregiver Dashboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F1E24),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Monitoring ${patients.length} active patients',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F3F7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00A3C4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF00A3C4),
                                    fontSize: 12,
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
                        final FamilyMemberModel member =
                            patient['member'] as FamilyMemberModel;
                        // Watch the async backend adherence for this patient
                        final adherenceAsync = ref.watch(
                          userAdherenceProvider(member.userId),
                        );
                        final int localAdherence =
                            patient['localAdherence'] as int;
                        final Color statusColor =
                            patient['statusColor'] as Color;
                        final Color ringColor = statusColor;

                        String? avatarUrl;
                        final normalizedName =
                            patient['name'].toString().toLowerCase();
                        if (normalizedName.contains('animesh')) {
                          avatarUrl =
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150';
                        } else if (normalizedName.contains('nirajan')) {
                          avatarUrl =
                              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150';
                        }

                        Widget avatarWidget;
                        if (avatarUrl != null) {
                          avatarWidget = ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.network(
                              avatarUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    width: 52,
                                    height: 52,
                                    color: (patient['avatarColor'] as Color)
                                        .withValues(alpha: 0.18),
                                    alignment: Alignment.center,
                                    child: Text(
                                      patient['initials'] as String,
                                      style: TextStyle(
                                        color:
                                            patient['avatarColor'] as Color,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                            ),
                          );
                        } else {
                          avatarWidget = Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (patient['avatarColor'] as Color)
                                  .withValues(alpha: 0.18),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              patient['initials'] as String,
                              style: TextStyle(
                                color: patient['avatarColor'] as Color,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        // Build the adherence ring: loading → shimmer,
                        // data → backend %, error → local fallback %
                        Widget adherenceRing = adherenceAsync.when(
                          loading: () => Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ringColor,
                              ),
                            ),
                          ),
                          error: (_, __) => _adherenceCircle(
                            localAdherence,
                            ringColor,
                            isLocal: true,
                          ),
                          data: (adherence) => _adherenceCircle(
                            adherence.adherencePercent,
                            ringColor,
                          ),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Left accent border indicator
                                    Container(
                                      width: 6,
                                      color: statusColor,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          18,
                                          18,
                                          18,
                                        ),
                                        child: Row(
                                          children: [
                                            // Avatar
                                            avatarWidget,
                                            const SizedBox(width: 14),
                                            // Name & compliance status
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    patient['name'] as String,
                                                    style: AppTheme.heading3
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 18,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        patient['statusIcon']
                                                            as IconData,
                                                        size: 16,
                                                        color: statusColor,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Flexible(
                                                        child: Text(
                                                          patient['statusText']
                                                              as String,
                                                          style: AppTheme
                                                              .bodySmall
                                                              .copyWith(
                                                                color:
                                                                    statusColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Backend-driven adherence ring
                                            adherenceRing,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                      ...alertLog.asMap().entries.map((entry) {
                        final index = entry.key;
                        final alert = entry.value;
                        final String fullText = alert['text'] as String;
                        final String highlight = alert['highlight'] as String;
                        final int highlightStart = fullText.indexOf(highlight);
                        final isLast = index == alertLog.length - 1;
                        final isDummy = alert['time'] == '--';

                        final actionText = highlightStart >= 0
                            ? fullText.substring(highlightStart + highlight.length).trim()
                            : fullText;

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
                                  if (!isLast)
                                    Container(
                                      width: 1.5,
                                      height: 60,
                                      color: AppTheme.dividerColor,
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),

                              // Text content styled with a separate badge for the patient name
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
                                    if (isDummy)
                                      Text(
                                        fullText,
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 14,
                                        ),
                                      )
                                    else
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF4FF),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              highlight,
                                              style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              actionText,
                                              style: TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
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
          onPressed: () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).push(MaterialPageRoute(builder: (_) => const QrScannerScreen()));
          },
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

  Map<String, Object> _buildLatestStatus(
      BuildContext context, DoseLogModel log, int missedCount) {
    if (log.isTaken) {
      return {
        'text': missedCount == 0 ? 'All doses taken' : 'Last dose taken',
        'color': const Color(0xFF00A3C4),
        'icon': Icons.check_circle_outline_rounded,
      };
    }

    if (log.isMissed) {
      final formattedTime = TimeOfDay.fromDateTime(log.scheduledAt).format(context);
      return {
        'text': 'Dose missed at $formattedTime',
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
