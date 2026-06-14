import '../../models/refill_model.dart';
import 'api_service.dart';

class RefillService {
  final ApiService _apiService;

  RefillService(this._apiService);

  Future<List<RefillModel>> getRefills() async {
    try {
      final response = await _apiService.client.get('/refills');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => RefillModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<RefillModel?> triggerRefill(String medicationId, bool isUrgent) async {
    try {
      final response = await _apiService.client.post('/refills', data: {
        'medicationId': medicationId,
        'isUrgent': isUrgent,
      });
      if (response.statusCode == 201) {
        return RefillModel.fromJson(response.data);
      }
    } catch (_) {}
    return null;
  }
}
