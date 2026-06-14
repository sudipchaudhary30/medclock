import 'package:hive_flutter/hive_flutter.dart';
import '../../config/app_constants.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Open necessary boxes
    await Hive.openBox(AppConstants.medicationsBox);
    await Hive.openBox(AppConstants.remindersBox);
    await Hive.openBox(AppConstants.doseLogsBox);
    await Hive.openBox(AppConstants.settingsBox);
    await Hive.openBox(AppConstants.pendingSyncBox);
  }

  Box getBox(String name) {
    return Hive.box(name);
  }

  Future<void> clearAll() async {
    await Hive.box(AppConstants.medicationsBox).clear();
    await Hive.box(AppConstants.remindersBox).clear();
    await Hive.box(AppConstants.doseLogsBox).clear();
    await Hive.box(AppConstants.settingsBox).clear();
    await Hive.box(AppConstants.pendingSyncBox).clear();
  }
}
