import '../../config/app_constants.dart';
import '../../models/medication_model.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

class MedicationService {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  MedicationService(this._apiService, this._localStorageService);

  Future<List<MedicationModel>> getMedications() async {
    try {
      final response = await _apiService.client.get('/medications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final meds = data.map((json) => MedicationModel.fromJson(json)).toList();
        
        // Save to cache
        final box = _localStorageService.getBox(AppConstants.medicationsBox);
        await box.clear();
        for (var med in meds) {
          await box.put(med.id, med.toJson());
        }
        return meds;
      }
    } catch (_) {
      // Offline fallback: load from local cache
      final box = _localStorageService.getBox(AppConstants.medicationsBox);
      return box.values
          .map((json) => MedicationModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return [];
  }

  Future<MedicationModel?> addMedication(MedicationModel medication) async {
    try {
      final response = await _apiService.client.post('/medications', data: medication.toJson());
      if (response.statusCode == 201) {
        final added = MedicationModel.fromJson(response.data);
        final box = _localStorageService.getBox(AppConstants.medicationsBox);
        await box.put(added.id, added.toJson());
        return added;
      }
    } catch (_) {
      // Offline fallback: Save locally and schedule sync
      final box = _localStorageService.getBox(AppConstants.medicationsBox);
      await box.put(medication.id, medication.toJson());
      
      final syncBox = _localStorageService.getBox(AppConstants.pendingSyncBox);
      await syncBox.put(medication.id, {
        'action': 'add_medication',
        'data': medication.toJson(),
      });
      return medication;
    }
    return null;
  }
}
