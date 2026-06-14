import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/refill_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/layout/mc_empty_state.dart';
import '../../widgets/cards/mc_refill_card.dart';

class RefillScreen extends ConsumerWidget {
  const RefillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refills = ref.watch(refillProvider);

    return McScaffold(
      title: 'Prescription Refills',
      showBackButton: true,
      body: refills.isEmpty
          ? McEmptyState(
              icon: Icons.history_edu_rounded,
              title: 'No pending refills',
              description: 'Your upcoming automatic pharmacy refill requests will appear here.',
            )
          : ListView.builder(
              itemCount: refills.length,
              itemBuilder: (context, index) {
                final refill = refills[index];
                return McRefillCard(
                  medicationName: 'Medication ${index + 1}',
                  refill: refill,
                );
              },
            ),
    );
  }
}
