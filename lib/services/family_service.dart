import '../../models/family_member_model.dart';
import 'api_service.dart';

class FamilyService {
  final ApiService _apiService;

  FamilyService(this._apiService);

  Future<FamilyGroupModel?> getFamilyGroup() async {
    try {
      final response = await _apiService.client.get('/family');
      if (response.statusCode == 200 && response.data != null) {
        return FamilyGroupModel.fromJson(response.data);
      }
    } catch (_) {}
    return null;
  }

  Future<FamilyMemberModel?> addFamilyMember(
    String name,
    String role,
    String colorHex, {
    String? userId,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/family/members',
        data: {
          if (userId != null) 'userId': userId,
          'name': name,
          'role': role,
          'color': colorHex,
        },
      );
      if (response.statusCode == 201) {
        return FamilyMemberModel.fromJson(response.data);
      }
    } catch (_) {}
    return null;
  }
}
