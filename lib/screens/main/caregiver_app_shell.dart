import 'package:flutter/material.dart';
import '../../widgets/layout/mc_caregiver_bottom_nav.dart';
import '../caregiver/caregiver_dashboard.dart';
import '../caregiver/caregiver_settings_screen.dart';
import '../dose_logging/dose_history_screen.dart';
import '../refill/refill_screen.dart';

class CaregiverAppShell extends StatefulWidget {
  const CaregiverAppShell({super.key});

  @override
  State<CaregiverAppShell> createState() => _CaregiverAppShellState();
}

class _CaregiverAppShellState extends State<CaregiverAppShell> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  void _onTap(int index) {
    if (index == _currentIndex) {
      _navKeys[index].currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _currentIndex = index);
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navKeys[index],
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => child, settings: settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildNavigator(0, const CaregiverDashboard()),
          _buildNavigator(1, const DoseHistoryScreen()),
          _buildNavigator(2, const RefillScreen()),
          _buildNavigator(3, const CaregiverSettingsScreen()),
        ],
      ),
      bottomNavigationBar: McCaregiverBottomNav(
        selectedIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
