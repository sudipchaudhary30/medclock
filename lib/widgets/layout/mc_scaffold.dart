import 'package:flutter/material.dart';
import 'mc_app_bar.dart';
import 'mc_bottom_nav.dart';

class McScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final int? selectedIndex;
  final void Function(int)? onTabTap;
  final bool isCaregiver;
  final Widget? fab;

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
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: McAppBar(
        title: title,
        actions: actions,
        showBackButton: showBackButton,
      ),
      body: SafeArea(child: body),
      floatingActionButton: fab,
      bottomNavigationBar: selectedIndex != null && onTabTap != null
          ? McBottomNav(
              selectedIndex: selectedIndex!,
              onTap: onTabTap!,
              isCaregiver: isCaregiver,
            )
          : null,
    );
  }
}
