import '../../config/app_constants.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

class SyncService {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  SyncService(this._apiService, this._localStorageService);

  Future<void> syncOfflineData() async {
    final syncBox = _localStorageService.getBox(AppConstants.pendingSyncBox);
    if (syncBox.isEmpty) return;

    final keys = List.from(syncBox.keys);
    for (var key in keys) {
      final item = syncBox.get(key);
      if (item == null) continue;

      try {
        final String action = item['action'];
        final data = Map<String, dynamic>.from(item['data'] ?? {});

        if (action == 'log_dose') {
          final response = await _apiService.client.post('/dose-logs', data: data);
          if (response.statusCode == 201) {
            await syncBox.delete(key);
          }
        } else if (action == 'add_medication') {
          final response = await _apiService.client.post('/medications', data: data);
          if (response.statusCode == 201) {
            await syncBox.delete(key);
          }
        } else if (action == 'snooze_reminder') {
          final String reminderId = item['id'];
          final int snoozes = item['snoozes'];
          final response = await _apiService.client.post('/reminders/$reminderId/snooze', data: {
            'remainingCount': snoozes,
          });
          if (response.statusCode == 200) {
            await syncBox.delete(key);
          }
        }
      } catch (_) {
        // Stop sync iteration if request fails due to lack of connection
        break;
      }
    }
  }
}
