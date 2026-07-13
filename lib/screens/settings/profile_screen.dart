import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/layout/mc_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final photoBase64 = user?.photoBase64;

    return McScaffold(
      title: 'Profile Settings',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primaryColor,
                foregroundImage: photoBase64 != null && photoBase64.isNotEmpty
                    ? MemoryImage(base64Decode(photoBase64))
                    : null,
                child: photoBase64 == null || photoBase64.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 32),
            Text('Name', style: AppTheme.labelText),
            const SizedBox(height: 4),
            Text(
              user?.name ?? 'N/A',
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            Text('Email Address', style: AppTheme.labelText),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'N/A',
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            Text('Registered Role', style: AppTheme.labelText),
            const SizedBox(height: 4),
            Text(
              (user?.role.name ?? 'patient').toUpperCase(),
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
