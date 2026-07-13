import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_constants.dart';
import '../providers/auth_provider.dart';
import '../services/local_storage_service.dart';

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

  factory SyncCodeInfo.fromJson(Map<String, dynamic> json) {
    return SyncCodeInfo(
      code: json['code'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      expiry: DateTime.parse(json['expiry'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'patientId': patientId,
      'patientName': patientName,
      'expiry': expiry.toIso8601String(),
    };
  }
}

class SyncCodeNotifier extends StateNotifier<SyncCodeInfo?> {
  final LocalStorageService _localStorageService;

  SyncCodeNotifier(this._localStorageService) : super(null) {
    _loadPersistedCode();
  }

  Future<void> _loadPersistedCode() async {
    try {
      final box = _localStorageService.getBox(AppConstants.syncCodeBox);
      final data = box.get('activeSyncCode');
      if (data is Map) {
        final persisted = SyncCodeInfo.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (DateTime.now().isAfter(persisted.expiry)) {
          clearCode();
          return;
        }
        state = persisted;
      }
    } catch (_) {
      clearCode();
    }
  }

  void generateCode(String patientId, String patientName) {
    final random = Random();
    final String code = List.generate(
      6,
      (_) => random.nextInt(10).toString(),
    ).join();
    state = SyncCodeInfo(
      code: code,
      patientId: patientId,
      patientName: patientName,
      expiry: DateTime.now().add(const Duration(hours: 24)),
    );
    _persistState();
  }

  bool validateCode(String enteredCode) {
    if (state == null) return false;
    final isExpired = DateTime.now().isAfter(state!.expiry);
    if (isExpired) {
      clearCode();
      return false;
    }
    return state!.code.replaceAll(' ', '') == enteredCode.replaceAll(' ', '');
  }

  void clearCode() {
    state = null;
    final box = _localStorageService.getBox(AppConstants.syncCodeBox);
    box.delete('activeSyncCode');
  }

  void _persistState() {
    final box = _localStorageService.getBox(AppConstants.syncCodeBox);
    if (state != null) {
      box.put('activeSyncCode', state!.toJson());
    } else {
      box.delete('activeSyncCode');
    }
  }
}

final syncCodeProvider = StateNotifierProvider<SyncCodeNotifier, SyncCodeInfo?>(
  (ref) {
    return SyncCodeNotifier(ref.watch(localStorageServiceProvider));
  },
);
