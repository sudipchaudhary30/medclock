import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../delivery/delivery_tracking_screen.dart';
import '../../models/medication_model.dart';
import '../../providers/medication_provider.dart';

class RefillScreen extends ConsumerWidget {
  const RefillScreen({super.key});

  int _getApproxDaysLeft(MedicationModel med) {
    if (med.id == 'mock-atorvastatin') return 2;
    if (med.id == 'mock-lisinopril') return 4;
    if (med.id == 'mock-metformin') return 21;
    // For real meds, assume a standard dose of 1 per day for simplicity.
    return med.currentSupply;
  }

  String _getStatusText(MedicationModel med) {
    if (med.id == 'mock-atorvastatin') return 'Low Stock';
    if (med.id == 'mock-lisinopril') return 'Refill Needed';
    if (med.id == 'mock-metformin') return 'In Stock';

    if (med.currentSupply == 0) return 'Out of Stock';
    if (med.currentSupply <= med.refillThreshold) {
      return med.currentSupply <= 5 ? 'Low Stock' : 'Refill Needed';
    }
    return 'In Stock';
  }

  void _handleRefillAction(
    BuildContext context,
    WidgetRef ref,
    MedicationModel med,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliveryTrackingScreen(
          medicationName: med.name,
          medicationId: med.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationProvider);

    // If active user medications list is empty, pre-populate with mock items matching mockup
    final List<MedicationModel> activeMedications = medications.isNotEmpty
        ? medications.where((m) => m.isActive).toList()
        : [
            MedicationModel(
              id: 'mock-atorvastatin',
              userId: 'mock-user',
              name: 'Atorvastatin',
              dosage: '20mg',
              form: 'pill',
              currentSupply: 5,
              totalSupply: 30,
              refillThreshold: 7,
              pharmacyId: 'Walgreens #1024',
            ),
            MedicationModel(
              id: 'mock-lisinopril',
              userId: 'mock-user',
              name: 'Lisinopril',
              dosage: '10mg',
              form: 'tablet',
              currentSupply: 8,
              totalSupply: 60,
              refillThreshold: 10,
              pharmacyId: 'CVS Pharmacy #492',
            ),
            MedicationModel(
              id: 'mock-metformin',
              userId: 'mock-user',
              name: 'Metformin',
              dosage: '500mg',
              form: 'pill',
              currentSupply: 42,
              totalSupply: 60,
              refillThreshold: 7,
              pharmacyId: 'Walgreens #1024',
            ),
          ];

    // Filter items into Urgent vs Adequate Supply lists
    final urgentRefills = activeMedications.where((med) {
      if (med.id.startsWith('mock-')) {
        return med.id != 'mock-metformin';
      }
      return med.currentSupply <= med.refillThreshold;
    }).toList();

    final adequateRefills = activeMedications.where((med) {
      if (med.id.startsWith('mock-')) {
        return med.id == 'mock-metformin';
      }
      return med.currentSupply > med.refillThreshold;
    }).toList();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overview Card
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF075E84), Color(0xFF147A9E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF075E84).withValues(alpha: 0.2),
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
                          Text(
                            'OVERVIEW',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${urgentRefills.length} Refills Needed',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'serif',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You have medications running low. Order today to ensure uninterrupted dosage.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Warning Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.80),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF6B6B),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Urgent Refills Section
              if (urgentRefills.isNotEmpty) ...[
                _buildSectionHeader('Urgent Refills'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: urgentRefills.length,
                  itemBuilder: (context, index) {
                    final med = urgentRefills[index];
                    return _buildMedicationCard(context, ref, med, true);
                  },
                ),
              ],

              // 3. Adequate Supply Section
              if (adequateRefills.isNotEmpty) ...[
                _buildSectionHeader('Adequate Supply'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: adequateRefills.length,
                  itemBuilder: (context, index) {
                    final med = adequateRefills[index];
                    return _buildMedicationCard(context, ref, med, false);
                  },
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0B3D66),
          fontFamily: 'serif',
        ),
      ),
    );
  }

  Widget _buildMedicationCard(
    BuildContext context,
    WidgetRef ref,
    MedicationModel med,
    bool isUrgent,
  ) {
    final statusText = _getStatusText(med);
    final approxDays = _getApproxDaysLeft(med);
    final accentColor = isUrgent
        ? const Color(0xFFFF6B6B)
        : const Color(0xFF45CB85);

    final badgeBg = isUrgent
        ? (statusText == 'Low Stock'
              ? const Color(0xFFFDECEB)
              : const Color(0xFFFFF2E6))
        : const Color(0xFFEAFAF1);
    final badgeTextColor = isUrgent
        ? (statusText == 'Low Stock'
              ? const Color(0xFFC0392B)
              : const Color(0xFFD35400))
        : const Color(0xFF27AE60);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Dosage & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${med.name} ${med.dosage}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F1E24),
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
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
            // Pharmacy Subtitle
            Row(
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  size: 16,
                  color: Color(0xFF6A7D90),
                ),
                const SizedBox(width: 4),
                Text(
                  med.pharmacyId ?? 'Local Pharmacy',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6A7D90),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Remaining Metrics & Action Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Metrics Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REMAINING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9AA7B3),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${med.currentSupply} / ${med.totalSupply} ${med.form == 'tablet' ? 'tablets' : 'pills'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F6D95),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Approx. $approxDays days left',
                      style: TextStyle(
                        fontSize: 12,
                        color: isUrgent
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFF7F8C8D),
                        fontWeight: isUrgent
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                // Action Button
                isUrgent
                    ? ElevatedButton.icon(
                        onPressed: () => _handleRefillAction(context, ref, med),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E6B94),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          elevation: 0,
                        ),
                        label: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 16,
                        ),
                        icon: const Text(
                          'Order Refill',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          if (med.id.startsWith('mock-')) {
                            // Mock navigation to details or show a snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Opening details for ${med.name}...',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          } else {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed(
                              AppRoutes.medicationDetail,
                              arguments: med,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0E6B94),
                          side: const BorderSide(color: Color(0xFF0E6B94)),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
