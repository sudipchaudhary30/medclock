import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';

class CaregiverAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  const CaregiverAppBar({super.key, this.showBackButton = false, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppTheme.textPrimary,
              ),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Image.asset(
        'assets/medclocklogo.png',
        height: 60,
        fit: BoxFit.contain,
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(AppRoutes.profile),
          icon: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFF6A7D90),
          ),
        ),
      ],
      shape: Border(
        bottom: BorderSide(
          color: Colors.black.withValues(alpha: 0.05),
          width: 0.8,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CaregiverSliverAppBar extends ConsumerWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  const CaregiverSliverAppBar({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppTheme.textPrimary,
              ),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Image.asset(
        'assets/medclocklogo.png',
        height: 60,
        fit: BoxFit.contain,
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(AppRoutes.profile),
          icon: const Icon(
            Icons.person_outline_rounded,
            color: Color(0xFF6A7D90),
          ),
        ),
      ],
      shape: Border(
        bottom: BorderSide(
          color: Colors.black.withValues(alpha: 0.05),
          width: 0.8,
        ),
      ),
    );
  }
}
