import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../../models/medication_model.dart';
import '../../providers/dose_log_provider.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/layout/mc_empty_state.dart';
import '../../widgets/cards/mc_dose_log_card.dart';

class DoseHistoryScreen extends ConsumerStatefulWidget {
  const DoseHistoryScreen({super.key});

  @override
  ConsumerState<DoseHistoryScreen> createState() => _DoseHistoryScreenState();
}

class _DoseHistoryScreenState extends ConsumerState<DoseHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(doseLogProvider);
    final medications = ref.watch(medicationProvider);

    return McScaffold(
      title: 'Dose History',
      body: logs.isEmpty
          ? McEmptyState(
              icon: Icons.history_rounded,
              title: 'No logs recorded',
              description:
                  'History of taken or missed doses will show up here.',
            )
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final med = medications.firstWhere(
                  (m) => m.id == log.medicationId,
                  orElse: () => MedicationModel(
                    id: log.medicationId,
                    userId: log.userId,
                    name: 'Medication',
                    dosage: 'N/A',
                  ),
                );

                return McDoseLogCard(
                  doseLog: log,
                  medicationName: med.name,
                  showPhoto: true,
                );
              },
            ),
    );
  }
}
