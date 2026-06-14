import 'package:flutter/material.dart';

class McBottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  final bool isCaregiver;

  const McBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.isCaregiver = false,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        if (isCaregiver)
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Family',
          )
        else
          const BottomNavigationBarItem(
            icon: Icon(Icons.medication_rounded),
            label: 'Meds',
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'Logs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}
