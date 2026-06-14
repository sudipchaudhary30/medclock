import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database storage
  final storageService = LocalStorageService();
  await storageService.init();

  runApp(
    const ProviderScope(
      child: MedClockApp(),
    ),
  );
}
