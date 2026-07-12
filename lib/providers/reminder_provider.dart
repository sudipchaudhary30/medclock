import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import 'auth_provider.dart';

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(
    ref.watch(apiServiceProvider),
    ref.watch(localStorageServiceProvider),
  );
});

class ReminderNotifier extends StateNotifier<List<ReminderModel>> {
  final ReminderService _reminderService;

  ReminderNotifier(this._reminderService) : super([]) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = await _reminderService.getReminders();
  }

  Future<bool> snoozeReminder(String id) async {
    final raw = state.firstWhere((r) => r.id == id);
    final updated = await _reminderService.snoozeReminder(id, raw.maxSnoozeCount - raw.currentSnoozeCount);
    if (updated != null) {
      state = state.map((r) => r.id == id ? updated : r).toList();
      return true;
    }
    return false;
  }

  Future<bool> addReminder(ReminderModel reminder) async {
    final saved = await _reminderService.addReminder(reminder);
    if (saved != null) {
      state = [...state, saved];
      return true;
    }
    return false;
  }

  Future<bool> updateReminder(ReminderModel reminder) async {
    final updated = await _reminderService.updateReminder(reminder);
    if (updated != null) {
      state = [
        for (final r in state)
          if (r.id == updated.id) updated else r,
      ];
      return true;
    }
    return false;
  }
}

final reminderProvider = StateNotifierProvider<ReminderNotifier, List<ReminderModel>>((ref) {
  return ReminderNotifier(ref.watch(reminderServiceProvider));
});
