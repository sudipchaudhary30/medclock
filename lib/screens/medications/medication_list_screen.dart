import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/layout/mc_empty_state.dart';
import '../../widgets/cards/mc_medication_card.dart';
import '../../widgets/buttons/mc_fab.dart';

class MedicationListScreen extends ConsumerStatefulWidget {
  const MedicationListScreen({super.key});

  @override
  ConsumerState<MedicationListScreen> createState() =>
      _MedicationListScreenState();
}

class _MedicationListScreenState extends ConsumerState<MedicationListScreen> {
  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(medicationProvider);

    return McScaffold(
      title: 'Medications',
      fab: McFab(
        icon: Icons.add_rounded,
        label: 'Add Medication',
        onTap: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.addMedication),
      ),
      body: medications.isEmpty
          ? McEmptyState(
              icon: Icons.medication_rounded,
              title: 'No medications added',
              description: 'Tap add button to catalog a new medication.',
            )
          : ListView.builder(
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final med = medications[index];
                return McMedicationCard(
                  medication: med,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.medicationDetail, arguments: med),
                );
              },
            ),
    );
  }
}
