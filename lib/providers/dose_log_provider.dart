import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dose_log_model.dart';
import '../services/dose_log_service.dart';
import 'auth_provider.dart';

final doseLogServiceProvider = Provider<DoseLogService>((ref) {
  return DoseLogService(
    ref.watch(apiServiceProvider),
    ref.watch(localStorageServiceProvider),
  );
});

class DoseLogNotifier extends StateNotifier<List<DoseLogModel>> {
  final DoseLogService _doseLogService;

  DoseLogNotifier(this._doseLogService) : super([]) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    state = await _doseLogService.getDoseLogs();
  }

  Future<bool> logDose(DoseLogModel log) async {
    final saved = await _doseLogService.logDose(log);
    if (saved != null) {
      state = [saved, ...state];
      return true;
    }
    return false;
  }
}

final doseLogProvider = StateNotifierProvider<DoseLogNotifier, List<DoseLogModel>>((ref) {
  return DoseLogNotifier(ref.watch(doseLogServiceProvider));
});
