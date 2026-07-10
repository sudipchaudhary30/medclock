import 'dart:io';
import 'package:dio/dio.dart' as dio;
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
          final syncedData = await _uploadLocalPhotos(data);
          final response = await _apiService.client.post(
            '/dose-logs',
            data: syncedData,
          );
          if (response.statusCode == 201) {
            await syncBox.delete(key);
          }
        } else if (action == 'add_medication') {
          final syncedData = await _uploadLocalPhotos(data);
          final response = await _apiService.client.post(
            '/medications',
            data: syncedData,
          );
          if (response.statusCode == 201) {
            await syncBox.delete(key);
          }
        } else if (action == 'update_medication') {
          final syncedData = await _uploadLocalPhotos(data);
          final String? id = syncedData['id'] as String?;
          if (id != null) {
            final response = await _apiService.client.put(
              '/medications/$id',
              data: syncedData,
            );
            if (response.statusCode == 200) {
              await syncBox.delete(key);
            }
          }
        } else if (action == 'delete_medication') {
          final String? id = data['id'] as String?;
          if (id != null) {
            final response = await _apiService.client.delete(
              '/medications/$id',
            );
            if (response.statusCode == 200) {
              await syncBox.delete(key);
            }
          }
        } else if (action == 'snooze_reminder') {
          final String reminderId = item['id'];
          final int snoozes = item['snoozes'];
          final response = await _apiService.client.post(
            '/reminders/$reminderId/snooze',
            data: {'remainingCount': snoozes},
          );
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

  Future<Map<String, dynamic>> _uploadLocalPhotos(
    Map<String, dynamic> data,
  ) async {
    final updated = Map<String, dynamic>.from(data);

    if (updated['pillPhotoUrl'] is String &&
        updated['pillPhotoUrl'].toString().isNotEmpty &&
        !updated['pillPhotoUrl'].toString().startsWith('http')) {
      final uploaded = await _uploadImage(updated['pillPhotoUrl'] as String);
      if (uploaded != null) {
        updated['pillPhotoUrl'] = uploaded;
      }
    }

    if (updated['photoUrl'] is String &&
        updated['photoUrl'].toString().isNotEmpty &&
        !updated['photoUrl'].toString().startsWith('http')) {
      final uploaded = await _uploadImage(updated['photoUrl'] as String);
      if (uploaded != null) {
        updated['photoUrl'] = uploaded;
      }
    }

    return updated;
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
        return response.data['url'] as String?;
      }
    } catch (_) {
      // ignore upload failure, reuse local path
    }
    return null;
  }
}
