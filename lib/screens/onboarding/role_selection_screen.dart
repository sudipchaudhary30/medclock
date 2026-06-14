import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Role')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'How will you be using MedClock?',
              style: AppTheme.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _RoleCard(
              icon: Icons.person_rounded,
              title: 'I am a Patient',
              description: 'I want to track my own medication schedule and stay on top of my doses.',
              onTap: () {
                final user = ref.read(authProvider);
                if (user != null) {
                  ref.read(authProvider.notifier).updateUser(user.copyWith(role: UserRole.patient));
                }
                Navigator.of(context).pushReplacementNamed(AppRoutes.medicationSetup);
              },
            ),
            const SizedBox(height: 20),
            _RoleCard(
              icon: Icons.people_rounded,
              title: 'I am a Caregiver',
              description: 'I want to manage medication regimens for linked family members and monitor their compliance.',
              onTap: () {
                final user = ref.read(authProvider);
                if (user != null) {
                  ref.read(authProvider.notifier).updateUser(user.copyWith(role: UserRole.caregiver));
                }
                Navigator.of(context).pushReplacementNamed(AppRoutes.caregiverDashboard);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 48, color: AppTheme.primaryColor),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
