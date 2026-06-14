import '../../config/app_constants.dart';
import '../../models/reminder_model.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

class ReminderService {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  ReminderService(this._apiService, this._localStorageService);

  Future<List<ReminderModel>> getReminders() async {
    try {
      final response = await _apiService.client.get('/reminders');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final reminders = data.map((json) => ReminderModel.fromJson(json)).toList();

        final box = _localStorageService.getBox(AppConstants.remindersBox);
        await box.clear();
        for (var r in reminders) {
          await box.put(r.id, r.toJson());
        }
        return reminders;
      }
    } catch (_) {
      final box = _localStorageService.getBox(AppConstants.remindersBox);
      return box.values
          .map((json) => ReminderModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return [];
  }

  Future<ReminderModel?> snoozeReminder(String reminderId, int remainingCount) async {
    try {
      final response = await _apiService.client.post('/reminders/$reminderId/snooze', data: {
        'remainingCount': remainingCount,
      });
      if (response.statusCode == 200) {
        final updated = ReminderModel.fromJson(response.data);
        final box = _localStorageService.getBox(AppConstants.remindersBox);
        await box.put(updated.id, updated.toJson());
        return updated;
      }
    } catch (_) {
      // Local snooze update
      final box = _localStorageService.getBox(AppConstants.remindersBox);
      final raw = box.get(reminderId);
      if (raw != null) {
        final reminder = ReminderModel.fromJson(Map<String, dynamic>.from(raw));
        final updated = reminder.copyWith(
          status: ReminderStatus.snoozed,
          currentSnoozeCount: reminder.currentSnoozeCount + 1,
        );
        await box.put(reminderId, updated.toJson());

        final syncBox = _localStorageService.getBox(AppConstants.pendingSyncBox);
        await syncBox.put('snooze_$reminderId', {
          'action': 'snooze_reminder',
          'id': reminderId,
          'snoozes': updated.currentSnoozeCount,
        });
        return updated;
      }
    }
    return null;
  }
}
