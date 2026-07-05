import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../../providers/family_provider.dart';

class CaregiverDashboard extends ConsumerStatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  ConsumerState<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends ConsumerState<CaregiverDashboard> {
  @override
  Widget build(BuildContext context) {
    final familyGroup = ref.watch(familyProvider);
    final isConnected = familyGroup != null && familyGroup.members.isNotEmpty;

    // Build patient cards
    final List<Map<String, dynamic>> patients = [
      {
        'name': 'Animesh Sharma',
        'adherence': 88,
        'statusText': 'All doses taken',
        'statusColor': const Color(0xFF00C48C),
        'statusIcon': Icons.check_circle_outline_rounded,
        'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43E?auto=format&fit=crop&w=120&q=80',
      },
      {
        'name': 'Nirajan Gurung',
        'adherence': 64,
        'statusText': 'Dose missed at 08:00 AM',
        'statusColor': const Color(0xFFFF6B6B),
        'statusIcon': Icons.error_outline_rounded,
        'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&q=80',
      },
    ];

    // Alert log entries
    final List<Map<String, dynamic>> alertLog = [
      {
        'time': '08:15 AM',
        'dotColor': const Color(0xFF00C48C),
        'text': 'Animesh confirmed Atorvastatin',
        'highlight': 'Animesh',
      },
      {
        'time': '08:02 AM',
        'dotColor': const Color(0xFFFF6B6B),
        'text': 'Nirajan missed Lisinopril',
        'highlight': 'Nirajan',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top transparent header with MedClock logo and profile icon
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/medclocklogo.png',
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F6D95),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.access_time_rounded,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'MedClock',
                            style: TextStyle(
                              color: Color(0xFF0F6D95),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile avatar on right
                    GestureDetector(
                      onTap: () => Navigator.of(context, rootNavigator: true)
                          .pushNamed(AppRoutes.profile),
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
                  ],
                ),
              ),
            ),

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
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6F2F7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Color(0xFF0F6D95),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Patients Linked',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F1E24),
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tap the scanner button below to scan a patient\'s invitation QR code and begin monitoring compliance.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF536A73),
                            height: 1.5,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                const Text(
                                  'Caregiver Dashboard',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F1E24),
                                    fontFamily: 'serif',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Monitoring ${patients.length} active patients',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9AA7B3),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // LIVE badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6F6EC),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00C48C),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF00C48C),
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
                      ...patients.map((patient) {
                        final int adherence = patient['adherence'] as int;
                        final Color statusColor = patient['statusColor'] as Color;
                        final Color ringColor = adherence >= 80 ? const Color(0xFF00C48C) : const Color(0xFFFF6B6B);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
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
                                // Rounded Image Avatar
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(patient['avatar'] as String),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Name & compliance status
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patient['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F1E24),
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
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: statusColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Custom Adherence circular progress ring
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: ringColor,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$adherence%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: ringColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // Alert Log section header
                      const Text(
                        'Alert Log',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F1E24),
                          fontFamily: 'serif',
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
                                    color: const Color(0xFFE5EFF2),
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
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF9AA7B3),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF4FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF0F1E24),
                                            height: 1.3,
                                          ),
                                          children: highlightStart >= 0
                                              ? [
                                                  if (highlightStart > 0)
                                                    TextSpan(
                                                      text: fullText.substring(0, highlightStart),
                                                    ),
                                                  TextSpan(
                                                    text: highlight,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF0F1E24),
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: fullText.substring(highlightStart + highlight.length),
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
        child: SizedBox(
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF26B0E8),
                  Color(0xFF0F6D95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F6D95).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => Navigator.of(context, rootNavigator: true)
                  .pushNamed(AppRoutes.qrScanner),
              backgroundColor: Colors.transparent,
              elevation: 0,
              highlightElevation: 0,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
