import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncCodeInfo {
  final String code;
  final String patientId;
  final String patientName;
  final DateTime expiry;

  SyncCodeInfo({
    required this.code,
    required this.patientId,
    required this.patientName,
    required this.expiry,
  });
}

class SyncCodeNotifier extends StateNotifier<SyncCodeInfo?> {
  SyncCodeNotifier() : super(null);

  void generateCode(String patientId, String patientName) {
    // Generate a random 6-digit code: e.g. "482910"
    final random = Random();
    final String code = List.generate(6, (_) => random.nextInt(10).toString()).join();
    state = SyncCodeInfo(
      code: code,
      patientId: patientId,
      patientName: patientName,
      expiry: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  bool validateCode(String enteredCode) {
    if (state == null) return false;
    final isExpired = DateTime.now().isAfter(state!.expiry);
    return state!.code.replaceAll(' ', '') == enteredCode.replaceAll(' ', '') && !isExpired;
  }

  void clearCode() {
    state = null;
  }
}

final syncCodeProvider = StateNotifierProvider<SyncCodeNotifier, SyncCodeInfo?>((ref) {
  return SyncCodeNotifier();
});
