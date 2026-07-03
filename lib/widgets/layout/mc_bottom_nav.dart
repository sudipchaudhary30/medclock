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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF0F6D95),
        unselectedItemColor: const Color(0xFF9AA7B3),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
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
              label: 'Medications',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
