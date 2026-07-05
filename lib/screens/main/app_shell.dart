import 'package:flutter/material.dart';
import '../../widgets/layout/mc_bottom_nav.dart';
import '../home/home_screen.dart';
import '../dose_logging/dose_history_screen.dart';
import '../refill/refill_screen.dart';
import '../settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  void _onTap(int index) {
    if (index == _currentIndex) {
      // pop to first route
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
          _buildNavigator(0, const HomeScreen()),
          _buildNavigator(1, const DoseHistoryScreen()),
          _buildNavigator(2, const RefillScreen()),
          _buildNavigator(3, const SettingsScreen()),
        ],
      ),
      bottomNavigationBar: McBottomNav(
        selectedIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
