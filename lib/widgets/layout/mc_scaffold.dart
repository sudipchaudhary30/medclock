import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'mc_app_bar.dart';
import 'mc_bottom_nav.dart';
import 'mc_caregiver_bottom_nav.dart';

class McScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final int? selectedIndex;
  final void Function(int)? onTabTap;
  final bool isCaregiver;
  final Widget? fab;
  final Color? backgroundColor;

  const McScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = false,
    this.selectedIndex,
    this.onTabTap,
    this.isCaregiver = false,
    this.fab,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget? bottomNav;
    if (selectedIndex != null && onTabTap != null) {
      bottomNav = isCaregiver
          ? McCaregiverBottomNav(
              selectedIndex: selectedIndex!,
              onTap: onTabTap!,
            )
          : McBottomNav(selectedIndex: selectedIndex!, onTap: onTabTap!);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.scaffoldBg,
      appBar: McAppBar(
        title: title,
        actions: actions,
        showBackButton: showBackButton,
      ),
      body: SafeArea(child: body),
      floatingActionButton: fab,
      bottomNavigationBar: bottomNav,
    );
  }
}
