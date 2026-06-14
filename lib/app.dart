import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';

class MedClockApp extends ConsumerWidget {
  const MedClockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return MaterialApp(
      title: 'MedClock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: user != null
          ? (user.role == UserRole.caregiver ? AppRoutes.caregiverDashboard : AppRoutes.home)
          : AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
