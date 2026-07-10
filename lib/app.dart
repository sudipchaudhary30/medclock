import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';
import 'config/scroll_behavior.dart';
import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'services/navigation_service.dart';

class MedClockApp extends ConsumerWidget {
  const MedClockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isInitialized = ref.watch(authInitializedProvider);

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'MedClock',
      scrollBehavior: const NoOverscrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: !isInitialized
          ? AppRoutes.splash
          : (user != null
                ? (user.role == UserRole.caregiver
                      ? AppRoutes.caregiverDashboard
                      : AppRoutes.home)
                : AppRoutes.onboarding),
      routes: AppRoutes.routes,
    );
  }
}
