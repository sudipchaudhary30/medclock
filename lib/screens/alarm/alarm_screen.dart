import 'package:flutter/material.dart';
import '../../config/routes.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/media/mc_pill_image.dart';

// class AlarmScreen extends StatelessWidget {
//   final String? medicationName;
//   final String? dosage;
//   final String? form;
//   final String? pillPhotoUrl;
//   final String? scheduledTime;
//   final String? instruction;
//   final bool isDaily;

//   const AlarmScreen({
//     super.key,
//     this.medicationName,
//     this.dosage,
//     this.form,
//     this.pillPhotoUrl,
//     this.scheduledTime,
//     this.instruction,
//     this.isDaily = true,
//   });

  @override
  Widget build(BuildContext context) {
    return McScaffold(
      title: '',
      showBackButton: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Image.asset('assets/medclocklogo.png', height: 64),
              const SizedBox(height: 24),
              const Text(
                'Time for your dose',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0D1E30),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                scheduledTime != null
                    ? 'Scheduled for $scheduledTime'
                    : 'Scheduled for your next dose',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF718296),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: McPillImage(
                      imageUrl: pillPhotoUrl,
                      size: 160,
                      fitToParentWidth: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicationName ?? 'Paracetamol',
                                  style: const TextStyle(
                                    color: Color(0xFF0D1E30),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${dosage ?? '500 mg'} • ${form ?? 'Tablet'}',
                                  style: const TextStyle(
                                    color: Color(0xFF5C7283),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F3FB),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              isDaily ? 'DAILY' : 'ONCE',
                              style: const TextStyle(
                                color: Color(0xFF0D6A95),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.water_drop,
                              color: Color(0xFF0D6A95),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                instruction ?? 'Take 1 pill with water',
                                style: const TextStyle(
                                  color: Color(0xFF0D1E30),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushReplacementNamed(AppRoutes.home);
                  },
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text(
                    'Taken',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushReplacementNamed(AppRoutes.home);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0D6A95)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Snooze 10 min',
                        style: TextStyle(
                          color: Color(0xFF0D6A95),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushReplacementNamed(AppRoutes.home);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD0363A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Skip Dose',
                        style: TextStyle(
                          color: Color(0xFFD0363A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
