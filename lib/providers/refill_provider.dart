import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/refill_model.dart';
import '../services/refill_service.dart';
import 'auth_provider.dart';

final refillServiceProvider = Provider<RefillService>((ref) {
  return RefillService(ref.watch(apiServiceProvider));
});

class RefillNotifier extends StateNotifier<List<RefillModel>> {
  final RefillService _refillService;

  RefillNotifier(this._refillService) : super([]) {
    loadRefills();
  }

  Future<void> loadRefills() async {
    state = await _refillService.getRefills();
  }

  Future<bool> triggerRefill(String medicationId, bool isUrgent) async {
    final response = await _refillService.triggerRefill(medicationId, isUrgent);
    if (response != null) {
      state = [response, ...state];
      return true;
    }
    return false;
  }
}

final refillProvider = StateNotifierProvider<RefillNotifier, List<RefillModel>>((ref) {
  return RefillNotifier(ref.watch(refillServiceProvider));
});
