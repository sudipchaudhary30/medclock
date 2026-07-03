import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes.dart';
import '../../providers/family_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/layout/mc_empty_state.dart';
import '../../widgets/cards/mc_family_member_card.dart';
import '../../widgets/buttons/mc_fab.dart';

class FamilyDashboardScreen extends ConsumerStatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  ConsumerState<FamilyDashboardScreen> createState() =>
      _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends ConsumerState<FamilyDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final familyGroup = ref.watch(familyProvider);

    return McScaffold(
      title: 'Family Dashboard',
      isCaregiver: true,
      fab: McFab(
        icon: Icons.person_add_rounded,
        label: 'Add Member',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.addMember),
      ),
      body: familyGroup == null || familyGroup.members.isEmpty
          ? McEmptyState(
              icon: Icons.group_outlined,
              title: 'No members in circle',
              description:
                  'Add members to your care circle to organize schedule plans.',
            )
          : ListView.builder(
              itemCount: familyGroup.members.length,
              itemBuilder: (context, index) {
                final member = familyGroup.members[index];
                return McFamilyMemberCard(
                  member: member,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.memberDetail, arguments: member),
                );
              },
            ),
    );
  }
}
