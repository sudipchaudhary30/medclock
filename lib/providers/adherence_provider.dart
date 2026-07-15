import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/adherence_model.dart';
import '../services/adherence_service.dart';
import 'auth_provider.dart';
import 'dose_log_provider.dart';

// ---------------------------------------------------------------------------
// Service provider
// ---------------------------------------------------------------------------

final adherenceServiceProvider = Provider<AdherenceService>((ref) {
  return AdherenceService(
    ref.watch(apiServiceProvider),
    ref.watch(localStorageServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Per-user adherence (used by caregiver dashboard, keyed by patient userId)
// ---------------------------------------------------------------------------

/// [FutureProvider.family] — provide the userId (String) as the key.
/// Automatically refreshes when dose logs change (via ref.watch).
final userAdherenceProvider =
    FutureProvider.family<AdherenceModel, String>((ref, userId) async {
  // Invalidate / refresh whenever dose logs are updated.
  ref.watch(doseLogProvider);
  final service = ref.watch(adherenceServiceProvider);
  return service.getUserAdherence(userId, days: 30);
});

// ---------------------------------------------------------------------------
// Current-user own adherence (patient view)
// ---------------------------------------------------------------------------

final myAdherenceProvider = FutureProvider<AdherenceModel>((ref) async {
  ref.watch(doseLogProvider);
  final service = ref.watch(adherenceServiceProvider);
  return service.getMyAdherence(days: 30);
});
