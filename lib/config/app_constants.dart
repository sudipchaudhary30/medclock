import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// MedClock App Constants
class AppConstants {
  AppConstants._();

  // API
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  static const int connectionTimeout = 10000;
  static const int receiveTimeout = 10000;
  static const int authRequestTimeout = 6000;

  // Auth
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Reminders
  static const int defaultSnoozeMinutes = 15;
  static const int maxSnoozeCount = 2;
  static const int doubleDoseBlockHours = 4;

  // Refill
  static const int defaultRefillThreshold = 7;
  static const int minRefillThreshold = 3;
  static const int maxRefillThreshold = 30;

  // Supply Alerts
  static const List<int> refillAlertDays = [14, 7, 3];

  // Photo
  static const int photoRetentionDays = 90;
  static const double photoMaxWidth = 1024;
  static const double photoMaxHeight = 1024;
  static const int photoQuality = 85;

  // UI
  static const double minFontSize = 16.0;
  static const double minTouchTarget = 48.0;
  static const double minButtonSpacing = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Quiet Hours
  static const String defaultQuietStart = '23:00';
  static const String defaultQuietEnd = '07:00';

  // History
  static const int historyDays = 30;

  // Onboarding
  static const int onboardingSteps = 5;

  // Family
  static const int maxFamilyMembers = 10;

  // Hive Boxes
  static const String medicationsBox = 'medications';
  static const String remindersBox = 'reminders';
  static const String doseLogsBox = 'dose_logs';
  static const String settingsBox = 'settings';
  static const String pendingSyncBox = 'pending_sync';
  static const String syncCodeBox = 'sync_codes';
}
