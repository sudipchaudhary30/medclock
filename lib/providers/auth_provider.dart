import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

// Services
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(apiServiceProvider)),
);
final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(),
);

// Auth State Notifier
final authInitializedProvider = StateProvider<bool>((ref) => false);

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(null) {
    _init();
  }

  Future<void> _init() async {
    try {
      state = await _authService.getCurrentUser();
    } catch (e) {
      state = null;
    } finally {
      _ref.read(authInitializedProvider.notifier).state = true;
    }
  }

  Future<bool> login(String email, String password) async {
    final user = await _authService.login(email, password);
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

  
  }) async {
    final user = await _authService.register(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
    );
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }

  void updateSettings(UserSettings settings) {
    if (state != null) {
      state = state!.copyWith(settings: settings);
    }
  }

  void updateUser(UserModel user) {
    state = user;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider), ref);
});
