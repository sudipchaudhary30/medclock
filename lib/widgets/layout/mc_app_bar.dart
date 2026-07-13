import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class McAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const McAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(title, style: AppTheme.heading3),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () {
                final user = ref.watch(authProvider);
                if (user != null) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                } else {
                  Navigator.of(context).pop();
                }
              },
            )
          : null,
      actions: [
        ...?actions,
        Builder(
          builder: (context) {
            final user = ref.watch(authProvider);
            final photoBase64 = user?.photoBase64;
            return IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.profile),
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                foregroundImage: photoBase64 != null && photoBase64.isNotEmpty
                    ? MemoryImage(base64Decode(photoBase64))
                    : null,
                child: photoBase64 == null || photoBase64.isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
