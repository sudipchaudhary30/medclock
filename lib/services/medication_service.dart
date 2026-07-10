import 'dart:io';
import 'package:dio/dio.dart' as dio;
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
        final meds = data
            .map((json) => MedicationModel.fromJson(json))
            .toList();

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
          .map(
            (json) => MedicationModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    }
    return [];
  }

  Future<MedicationModel?> addMedication(MedicationModel medication) async {
    try {
      // If a local image path is provided, upload it first
      String? photoUrl = medication.pillPhotoUrl;
      if (photoUrl != null &&
          photoUrl.isNotEmpty &&
          !photoUrl.startsWith('http')) {
        final uploaded = await _uploadImage(photoUrl);
        if (uploaded != null) photoUrl = uploaded;
      }

      final data = medication.copyWith(pillPhotoUrl: photoUrl).toJson();
      final response = await _apiService.client.post(
        '/medications',
        data: data,
      );
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

  Future<MedicationModel?> updateMedication(MedicationModel medication) async {
    try {
      // Upload local image first if necessary
      String? photoUrl = medication.pillPhotoUrl;
      if (photoUrl != null &&
          photoUrl.isNotEmpty &&
          !photoUrl.startsWith('http')) {
        final uploaded = await _uploadImage(photoUrl);
        if (uploaded != null) photoUrl = uploaded;
      }

      final data = medication.copyWith(pillPhotoUrl: photoUrl).toJson();
      final response = await _apiService.client.put(
        '/medications/${medication.id}',
        data: data,
      );
      if (response.statusCode == 200) {
        final updated = MedicationModel.fromJson(response.data);
        final box = _localStorageService.getBox(AppConstants.medicationsBox);
        await box.put(updated.id, updated.toJson());
        return updated;
      }
    } catch (_) {
      // Offline fallback: update local cache and schedule sync
      final box = _localStorageService.getBox(AppConstants.medicationsBox);
      await box.put(medication.id, medication.toJson());
      final syncBox = _localStorageService.getBox(AppConstants.pendingSyncBox);
      await syncBox.put(medication.id, {
        'action': 'update_medication',
        'data': medication.toJson(),
      });
      return medication;
    }
    return null;
  }

  Future<String?> _uploadImage(String localPath) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;
      final fileName = localPath.split(Platform.pathSeparator).last;
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(localPath, filename: fileName),
      });
      final response = await _apiService.client.post(
        '/uploads',
        data: formData,
        options: dio.Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      if (response.statusCode == 200) {
        final url = response.data['url'] as String?;
        return url;
      }
    } catch (e) {
      // ignore upload failure, fallback to local path
    }
    return null;
  }

  Future<bool> deleteMedication(String id) async {
    try {
      final response = await _apiService.client.delete('/medications/$id');
      if (response.statusCode == 200) {
        final box = _localStorageService.getBox(AppConstants.medicationsBox);
        await box.delete(id);
        return true;
      }
    } catch (_) {
      final box = _localStorageService.getBox(AppConstants.medicationsBox);
      await box.delete(id);
      final syncBox = _localStorageService.getBox(AppConstants.pendingSyncBox);
      await syncBox.put(id, {
        'action': 'delete_medication',
        'data': {'id': id},
      });
      return true;
    }
    return false;
  }
}
