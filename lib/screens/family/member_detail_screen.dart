import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/family_member_model.dart';
import '../../widgets/layout/mc_scaffold.dart';
import '../../widgets/common/mc_avatar.dart';

class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final member = ModalRoute.of(context)!.settings.arguments as FamilyMemberModel;

    return McScaffold(
      title: member.name,
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: McAvatar(
                initials: member.initials,
                color: member.color,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              member.name,
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              member.role.toUpperCase(),
              style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Medication Plans'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Compliance Logs'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
