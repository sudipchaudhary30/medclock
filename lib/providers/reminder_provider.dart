
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';
import 'notification_provider.dart';

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(
    ref.watch(apiServiceProvider),
    ref.watch(localStorageServiceProvider),
  );
});

class ReminderNotifier extends StateNotifier<List<ReminderModel>> {
  final ReminderService _reminderService;
  final NotificationService _notificationService;

  ReminderNotifier(this._reminderService, this._notificationService)
    : super([]) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = await _reminderService.getReminders();
  }

  Future<bool> snoozeReminder(String id) async {
    final raw = state.firstWhere((r) => r.id == id);
    final updated = await _reminderService.snoozeReminder(
      id,
      raw.maxSnoozeCount - raw.currentSnoozeCount,
    );
    if (updated != null) {
      state = state.map((r) => r.id == id ? updated : r).toList();
      return true;
    }
    return false;
  }

  Future<bool> addReminder(
    ReminderModel reminder, {
    String? medicationName,
    String? dosage,
    String? form,
    String? pillPhotoUrl,
    String? instruction,
  }) async {
    final saved = await _reminderService.addReminder(reminder);
    if (saved != null) {
      state = [...state, saved];
      try {
        await _notificationService.scheduleWeeklyReminderNotifications(
          reminderId: saved.id,
          title: 'Time for your medication',
          body:
              'Take ${medicationName ?? 'your medication'} at ${saved.scheduledTime}',
          scheduledTime: saved.scheduledTime,
          days: saved.days,
          medicationName: medicationName,
          dosage: dosage,
          form: form,
          pillPhotoUrl: pillPhotoUrl,
          instruction: instruction,
        );
      } catch (_) {
        // Ignore scheduling errors so medication save still succeeds.
      }
      return true;
    }
    return false;
  }

  Future<bool> updateReminder(
    ReminderModel reminder, {
    String? medicationName,
    String? dosage,
    String? form,
    String? pillPhotoUrl,
    String? instruction,
  }) async {
    final existing = state.firstWhere(
      (r) => r.id == reminder.id,
      orElse: () => reminder,
    );
    final updated = await _reminderService.updateReminder(reminder);
    if (updated != null) {
      try {
        await _notificationService.cancelReminderNotifications(
          existing.id,
          existing.days,
        );
        await _notificationService.scheduleWeeklyReminderNotifications(
          reminderId: updated.id,
          title: 'Time for your medication',
          body:
              'Take ${medicationName ?? 'your medication'} at ${updated.scheduledTime}',
          scheduledTime: updated.scheduledTime,
          days: updated.days,
          medicationName: medicationName,
          dosage: dosage,
          form: form,
          pillPhotoUrl: pillPhotoUrl,
          instruction: instruction,
        );
      } catch (_) {
        // Ignore scheduling errors so reminder update still succeeds.
      }
      state = [
        for (final r in state)
          if (r.id == updated.id) updated else r,
      ];
      return true;
    }
    return false;
  }
}

final reminderProvider =
    StateNotifierProvider<ReminderNotifier, List<ReminderModel>>((ref) {
      return ReminderNotifier(
        ref.watch(reminderServiceProvider),
        ref.watch(notificationServiceProvider),
      );
    });
