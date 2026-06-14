import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(ref.watch(apiServiceProvider));
  service.init();
  return service;
});

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  final NotificationService _notificationService;

  NotificationNotifier(this._notificationService) : super([]) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = await _notificationService.getNotifications();
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
  return NotificationNotifier(ref.watch(notificationServiceProvider));
});
