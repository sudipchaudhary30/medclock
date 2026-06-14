import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../../providers/family_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/layout/mc_empty_state.dart';
import '../../widgets/layout/mc_section_header.dart';
import '../../widgets/cards/mc_family_member_card.dart';
import '../../widgets/buttons/mc_fab.dart';

class CaregiverDashboard extends ConsumerStatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  ConsumerState<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends ConsumerState<CaregiverDashboard> {
  final int _selectedIndex = 0;

  void _onTabTap(int index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.familyDashboard);
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.doseHistory);
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyGroup = ref.watch(familyProvider);

    return McScaffold(
      title: 'Caregiver Dashboard',
      selectedIndex: _selectedIndex,
      onTabTap: _onTabTap,
      isCaregiver: true,
      fab: McFab(
        icon: Icons.person_add_rounded,
        label: 'Add Member',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.addMember),
      ),
      body: familyGroup == null || familyGroup.members.isEmpty
          ? McEmptyState(
              icon: Icons.people_outline_rounded,
              title: 'No linked family members',
              description: 'Link patients to monitor their medication regimens remotely.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                McSectionHeader(
                  title: 'Monitored Patients',
                  actionLabel: 'Settings',
                  onAction: () => Navigator.of(context).pushNamed(AppRoutes.caregiverSettings),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: familyGroup.members.length,
                    itemBuilder: (context, index) {
                      final member = familyGroup.members[index];
                      return McFamilyMemberCard(
                        member: member,
                        medicationCount: 3, // Mock medication count
                        lastDoseStatus: 'taken',
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.memberDetail,
                          arguments: member,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
