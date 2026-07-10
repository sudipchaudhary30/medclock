import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';
import 'auth_provider.dart';

final medicationServiceProvider = Provider<MedicationService>((ref) {
  return MedicationService(
    ref.watch(apiServiceProvider),
    ref.watch(localStorageServiceProvider),
  );
});

class MedicationNotifier extends StateNotifier<List<MedicationModel>> {
  final MedicationService _medicationService;

  MedicationNotifier(this._medicationService) : super([]) {
    loadMedications();
  }

  Future<void> loadMedications() async {
    state = await _medicationService.getMedications();
  }

  Future<bool> addMedication(MedicationModel medication) async {
    final added = await _medicationService.addMedication(medication);
    if (added != null) {
      state = [...state, added];
      return true;
    }
    return false;
  }

  Future<bool> updateMedication(MedicationModel medication) async {
    final updated = await _medicationService.updateMedication(medication);
    if (updated != null) {
      state = [
        for (final m in state)
          if (m.id == updated.id) updated else m,
      ];
      return true;
    }
    return false;
  }

  Future<bool> deleteMedication(String id) async {
    final success = await _medicationService.deleteMedication(id);
    if (success) {
      state = state.where((m) => m.id != id).toList();
      return true;
    }
    return false;
  }
}

final medicationProvider =
    StateNotifierProvider<MedicationNotifier, List<MedicationModel>>((ref) {
      return MedicationNotifier(ref.watch(medicationServiceProvider));
    });
