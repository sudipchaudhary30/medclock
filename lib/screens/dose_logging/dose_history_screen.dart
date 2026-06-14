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
  final int _selectedIndex = 2;

  void _onTabTap(int index) {
    if (index == 2) return;
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.medicationList);
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(doseLogProvider);
    final medications = ref.watch(medicationProvider);

    return McScaffold(
      title: 'Dose History',
      selectedIndex: _selectedIndex,
      onTabTap: _onTabTap,
      body: logs.isEmpty
          ? McEmptyState(
              icon: Icons.history_rounded,
              title: 'No logs recorded',
              description: 'History of taken or missed doses will show up here.',
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
