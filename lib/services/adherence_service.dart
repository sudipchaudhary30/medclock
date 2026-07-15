import '../models/adherence_model.dart';
import '../models/dose_log_model.dart';
import 'api_service.dart';
import 'local_storage_service.dart';
import '../../config/app_constants.dart';

/// Fetches adherence rate data from the backend, with an automatic
/// local fallback that calculates the rate from cached dose logs.
class AdherenceService {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  AdherenceService(this._apiService, this._localStorageService);

  // ---------------------------------------------------------------------------
  // Backend calls
  // ---------------------------------------------------------------------------

  /// Returns adherence data for the currently authenticated user.
  Future<AdherenceModel> getMyAdherence({int days = 30}) async {
    try {
      final response = await _apiService.client
          .get('/dose-logs/adherence', queryParameters: {'days': days});
      if (response.statusCode == 200) {
        return AdherenceModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (_) {
      // Fall through to local calculation.
    }
    return _computeLocalAdherence('', days: days);
  }

  /// Returns adherence data for a specific patient (used by caregivers).
  /// Hits  GET /dose-logs/adherence/:userId?days=30
  Future<AdherenceModel> getUserAdherence(
    String userId, {
    int days = 30,
  }) async {
    if (userId.isEmpty) return AdherenceModel.empty(userId);

    try {
      final response = await _apiService.client.get(
        '/dose-logs/adherence/$userId',
        queryParameters: {'days': days},
      );
      if (response.statusCode == 200) {
        return AdherenceModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } catch (_) {
      // Fall through to local calculation.
    }
    return _computeLocalAdherence(userId, days: days);
  }

  // ---------------------------------------------------------------------------
  // Local fallback: compute from cached dose logs
  // ---------------------------------------------------------------------------

  AdherenceModel _computeLocalAdherence(String userId, {int days = 30}) {
    final box = _localStorageService.getBox(AppConstants.doseLogsBox);
    final cutoff = DateTime.now().subtract(Duration(days: days));

    final allLogs = box.values
        .map(
          (raw) => DoseLogModel.fromJson(
            Map<String, dynamic>.from(raw as Map),
          ),
        )
        .where((log) {
      final withinWindow = log.scheduledAt.isAfter(cutoff);
      if (userId.isEmpty) return withinWindow;
      return withinWindow &&
          (log.userId == userId || log.familyMemberId == userId);
    }).toList();

    if (allLogs.isEmpty) return AdherenceModel.empty(userId);

    final taken = allLogs.where((l) => l.isTaken).length;
    final missed = allLogs.where((l) => l.isMissed).length;
    final skipped = allLogs.where((l) => l.isSkipped).length;
    final total = allLogs.length;
    final rate = (taken / total) * 100.0;

    return AdherenceModel(
      userId: userId,
      periodDays: days,
      takenCount: taken,
      missedCount: missed,
      skippedCount: skipped,
      totalScheduled: total,
      adherenceRate: rate,
      calculatedAt: DateTime.now(),
    );
  }
}
