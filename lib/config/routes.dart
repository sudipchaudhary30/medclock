import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/onboarding/medication_setup_screen.dart';
import '../screens/main/app_shell.dart';
import '../screens/main/caregiver_app_shell.dart';
import '../screens/reminders/reminder_screen.dart';
import '../screens/reminders/reminder_list_screen.dart';
import '../screens/medications/medication_list_screen.dart';
import '../screens/medications/medication_detail_screen.dart';
import '../screens/medications/add_medication_screen.dart';
import '../screens/medications/pill_photo_screen.dart';
import '../screens/dose_logging/dose_confirm_screen.dart';
import '../screens/dose_logging/dose_history_screen.dart';
import '../screens/dose_logging/missed_dose_screen.dart';
import '../screens/caregiver/caregiver_settings_screen.dart';
import '../screens/caregiver/daily_summary_screen.dart';
import '../screens/caregiver/qr_scanner_screen.dart';
import '../screens/caregiver/adaptive_reminder_screen.dart';
import '../screens/family/family_dashboard_screen.dart';
import '../screens/family/add_member_screen.dart';
import '../screens/family/member_detail_screen.dart';
import '../screens/refill/refill_screen.dart';
import '../screens/refill/refill_settings_screen.dart';
import '../screens/delivery/delivery_tracking_screen.dart';
import '../screens/delivery/pharmacy_map_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/reports/export_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/settings/accessibility_settings_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/settings/edit_profile_screen.dart';
import '../screens/settings/qr_link_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Splash & Welcome
  static const String splash = '/splash';
  static const String welcome = '/welcome';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Onboarding
  static const String onboarding = '/onboarding';
  static const String medicationSetup = '/medication-setup';

  // Home
  static const String home = '/home';

  // Reminders
  static const String reminder = '/reminder';
  static const String reminderList = '/reminder-list';

  // Medications
  static const String medicationList = '/medications';
  static const String medicationDetail = '/medication-detail';
  static const String addMedication = '/add-medication';
  static const String pillPhoto = '/pill-photo';

  // Dose Logging
  static const String doseConfirm = '/dose-confirm';
  static const String doseHistory = '/dose-history';
  static const String missedDose = '/missed-dose';

  // Caregiver
  static const String caregiverDashboard = '/caregiver-dashboard';
  static const String caregiverSettings = '/caregiver-settings';
  static const String dailySummary = '/daily-summary';
  static const String qrScanner = '/qr-scanner';
  static const String adaptiveReminder = '/adaptive-reminder';

  // Family
  static const String familyDashboard = '/family-dashboard';
  static const String addMember = '/add-member';
  static const String memberDetail = '/member-detail';

  // Refill
  static const String refill = '/refill';
  static const String refillSettings = '/refill-settings';

  // Delivery
  static const String deliveryTracking = '/delivery-tracking';
  static const String pharmacyMap = '/pharmacy-map';

  // Reports
  static const String reports = '/reports';
  static const String export = '/export';

  // Settings
  static const String settings = '/settings';
  static const String notificationSettings = '/notification-settings';
  static const String accessibilitySettings = '/accessibility-settings';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String qrLink = '/qr-link';

  static Map<String, WidgetBuilder> get routes {
    return {
      // Shared entry flow
      splash: (_) => const SplashScreen(),
      welcome: (_) => const WelcomeScreen(),
      login: (_) => const LoginScreen(),
      register: (_) => const RegisterScreen(),
      forgotPassword: (_) => const ForgotPasswordScreen(),
      onboarding: (_) => const OnboardingScreen(),
      medicationSetup: (_) => const MedicationSetupScreen(),

      // Shared screens for both patients and caregivers
      home: (_) => const AppShell(),
      reminder: (_) => const ReminderScreen(),
      reminderList: (_) => const ReminderListScreen(),
      medicationList: (_) => const MedicationListScreen(),
      medicationDetail: (_) => const MedicationDetailScreen(),
      addMedication: (_) => const AddMedicationScreen(),
      pillPhoto: (_) => const PillPhotoScreen(),
      doseConfirm: (_) => const DoseConfirmScreen(),
      doseHistory: (_) => const DoseHistoryScreen(),
      missedDose: (_) => const MissedDoseScreen(),

      // Caregiver-only screens
      caregiverDashboard: (_) => const CaregiverAppShell(),
      caregiverSettings: (_) => const CaregiverSettingsScreen(),
      dailySummary: (_) => const DailySummaryScreen(),
      qrScanner: (_) => const QrScannerScreen(),
      adaptiveReminder: (_) => const AdaptiveReminderScreen(),
      familyDashboard: (_) => const FamilyDashboardScreen(),
      addMember: (_) => const AddMemberScreen(),
      memberDetail: (_) => const MemberDetailScreen(),

      // Utility and settings screens shared across roles
      refill: (_) => const RefillScreen(),
      refillSettings: (_) => const RefillSettingsScreen(),
      deliveryTracking: (_) => const DeliveryTrackingScreen(),
      pharmacyMap: (_) => const PharmacyMapScreen(),
      reports: (_) => const ReportsScreen(),
      export: (_) => const ExportScreen(),
      settings: (_) => const SettingsScreen(),
      editProfile: (_) => const EditProfileScreen(),
      notificationSettings: (_) => const NotificationSettingsScreen(),
      accessibilitySettings: (_) => const AccessibilitySettingsScreen(),
      profile: (_) => const ProfileScreen(),
      qrLink: (_) => const QrLinkScreen(),
    };
  }
}
