import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/app_constants.dart';
import '../../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final _secureStorage = const FlutterSecureStorage();

  AuthService(this._apiService);

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _apiService.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userData = response.data['user'];

        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        await _secureStorage.write(key: AppConstants.userKey, value: jsonEncode(userData));

        return UserModel.fromJson(userData);
      }
    } catch (e) {
      // Offline fallback: check cached user key if server is unreachable
      final cachedUser = await _secureStorage.read(key: AppConstants.userKey);
      if (cachedUser != null) {
        return UserModel.fromJson(jsonDecode(cachedUser));
      }
    }
    return null;
  }

  Future<UserModel?> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      final response = await _apiService.client.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
        'role': role.name,
        'phone': phone,
      });

      if (response.statusCode == 201) {
        final token = response.data['token'];
        final userData = response.data['user'];

        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
        await _secureStorage.write(key: AppConstants.userKey, value: jsonEncode(userData));

        return UserModel.fromJson(userData);
      }
    } catch (_) {
      // Network failure
    }
    return null;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.userKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final cachedUser = await _secureStorage.read(key: AppConstants.userKey);
    if (cachedUser != null) {
      return UserModel.fromJson(jsonDecode(cachedUser));
    }
    return null;
  }
}
