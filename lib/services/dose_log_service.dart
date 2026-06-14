import '../../config/app_constants.dart';
import '../../models/dose_log_model.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

class DoseLogService {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  DoseLogService(this._apiService, this._localStorageService);

  Future<List<DoseLogModel>> getDoseLogs() async {
    try {
      final response = await _apiService.client.get('/dose-logs');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final logs = data.map((json) => DoseLogModel.fromJson(json)).toList();

        final box = _localStorageService.getBox(AppConstants.doseLogsBox);
        await box.clear();
        for (var l in logs) {
          await box.put(l.id, l.toJson());
        }
        return logs;
      }
    } catch (_) {
      final box = _localStorageService.getBox(AppConstants.doseLogsBox);
      return box.values
          .map((json) => DoseLogModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return [];
  }

  Future<DoseLogModel?> logDose(DoseLogModel doseLog) async {
    try {
      final response = await _apiService.client.post('/dose-logs', data: doseLog.toJson());
      if (response.statusCode == 201) {
        final saved = DoseLogModel.fromJson(response.data);
        final box = _localStorageService.getBox(AppConstants.doseLogsBox);
        await box.put(saved.id, saved.toJson());
        return saved;
      }
    } catch (_) {
      // Offline cache
      final box = _localStorageService.getBox(AppConstants.doseLogsBox);
      await box.put(doseLog.id, doseLog.toJson());

      final syncBox = _localStorageService.getBox(AppConstants.pendingSyncBox);
      await syncBox.put('doselog_${doseLog.id}', {
        'action': 'log_dose',
        'data': doseLog.toJson(),
      });
      return doseLog.copyWith(syncedToServer: false);
    }
    return null;
  }
}
