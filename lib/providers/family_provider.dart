import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_member_model.dart';
import '../services/family_service.dart';
import 'auth_provider.dart';

final familyServiceProvider = Provider<FamilyService>((ref) {
  return FamilyService(ref.watch(apiServiceProvider));
});

class FamilyNotifier extends StateNotifier<FamilyGroupModel?> {
  final FamilyService _familyService;

  FamilyNotifier(this._familyService) : super(null) {
    loadFamilyGroup();
  }

  Future<void> loadFamilyGroup() async {
    state = await _familyService.getFamilyGroup();
  }

  Future<bool> addMember(String name, String role, String colorHex) async {
    final member = await _familyService.addFamilyMember(name, role, colorHex);
    if (member != null) {
      if (state != null) {
        state = FamilyGroupModel(
          id: state!.id,
          name: state!.name,
          createdBy: state!.createdBy,
          members: [...state!.members, member],
          createdAt: state!.createdAt,
        );
      }
      return true;
    }
    return false;
  }
}

final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyGroupModel?>((ref) {
  return FamilyNotifier(ref.watch(familyServiceProvider));
});
