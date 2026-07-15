import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../../providers/medication_provider.dart';
import '../../models/medication_model.dart';
import 'pharmacy_map_screen.dart';

class DeliveryTrackingScreen extends ConsumerStatefulWidget {
  final String? medicationName;
  final String? medicationId;

  const DeliveryTrackingScreen({
    super.key,
    this.medicationName,
    this.medicationId,
  });

  @override
  ConsumerState<DeliveryTrackingScreen> createState() =>
      _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState
    extends ConsumerState<DeliveryTrackingScreen> {
  String _selectedDeliveryMethod = 'home'; // 'home' or 'pharmacy'

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                // Title (larger, centered feel)
                const Text(
                  'Delivery Method',
                  style: TextStyle(
                    color: Color(0xFF0D1E30),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose how you\'d like to receive your medication.',
                  style: TextStyle(color: Color(0xFF6F7D8E), fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Pharmacy Pickup Card
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedDeliveryMethod = 'pharmacy');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _selectedDeliveryMethod == 'pharmacy'
                          ? const Color(0xFFEDF8FB)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedDeliveryMethod == 'pharmacy'
                            ? const Color(0xFF0E6B94)
                            : const Color(0xFFE8EEF2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.store_outlined,
                            color: Color(0xFF0E6B94),
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Pharmacy Pickup',
                          style: TextStyle(
                            color: Color(0xFF0D1E30),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PICKUP',
                          style: TextStyle(
                            color: Color(0xFF6F7D8E),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Home Delivery Card
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedDeliveryMethod = 'home');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: _selectedDeliveryMethod == 'home'
                          ? const LinearGradient(
                              colors: [Color(0xFF1E7AA1), Color(0xFF0E6B94)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _selectedDeliveryMethod == 'home'
                          ? null
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedDeliveryMethod == 'home'
                            ? Colors.transparent
                            : const Color(0xFFE8EEF2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: _selectedDeliveryMethod == 'home'
                                      ? Colors.white.withValues(alpha: 0.15)
                                      : const Color(0xFFEAF4FB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.local_shipping_outlined,
                                  color: _selectedDeliveryMethod == 'home'
                                      ? Colors.white
                                      : const Color(0xFF0E6B94),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Home Delivery',
                                style: TextStyle(
                                  color: _selectedDeliveryMethod == 'home'
                                      ? Colors.white
                                      : const Color(0xFF0D1E30),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'SELECTED',
                                style: TextStyle(
                                  color: _selectedDeliveryMethod == 'home'
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : const Color(0xFF6F7D8E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedDeliveryMethod == 'home')
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Delivery Address Section
                if (_selectedDeliveryMethod == 'home')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'DELIVERY ADDRESS',
                            style: TextStyle(
                              color: Color(0xFF6F7D8E),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            label: const Text(
                              'Change',
                              style: TextStyle(
                                color: Color(0xFF0E6B94),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF0E6B94),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE8EEF2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF4FB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF0E6B94),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Janaeson R. Miller',
                                    style: TextStyle(
                                      color: Color(0xFF0D1E30),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '124 High-Utility District, Medical\nPlaza Suite 200\nSan Francisco, CA 94103',
                                    style: TextStyle(
                                      color: Color(0xFF6F7D8E),
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                const SizedBox(height: 8),

                // Confirm Delivery Button
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text('Confirm Delivery'),
                        content: const Text(
                          'Are you sure you want to confirm this delivery request?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.pop(dialogContext);
                              if (widget.medicationId != null) {
                                final meds = ref.read(medicationProvider);
                                final med = meds.firstWhere(
                                  (m) => m.id == widget.medicationId,
                                  orElse: () => MedicationModel(
                                    id: widget.medicationId!,
                                    userId: '',
                                    name: widget.medicationName ?? 'Medication',
                                    dosage: '',
                                    currentSupply: 0,
                                    totalSupply: 0,
                                    refillThreshold: 0,
                                  ),
                                );
                                final updatedMed = med.copyWith(
                                  currentSupply:
                                      med.totalSupply > med.refillThreshold
                                      ? med.totalSupply
                                      : med.refillThreshold + 7,
                                );
                                await ref
                                    .read(medicationProvider.notifier)
                                    .updateMedication(updatedMed);
                              }
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _selectedDeliveryMethod == 'home'
                                        ? 'Delivery address confirmed. Preparing shipment...'
                                        : 'Your refill is ready for pickup at the pharmacy.',
                                  ),
                                  backgroundColor: const Color(0xFF0F6D95),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E6B94),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E6B94),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Delivery',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),

                // Live Courier Tracking floating action style
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PharmacyMapScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.local_shipping_outlined,
                      size: 18,
                      color: Color(0xFFFFFFFF),
                    ),
                    label: const Text('Live Courier Tracking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E6B94),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
