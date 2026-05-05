import '../../core/network/api_client.dart';
import '../../core/network/storage_service.dart';
import '../models/user_model.dart';

/// Authentication Service
class AuthService {
  final ApiClient _api;
  final StorageService _storage;

  AuthService(this._api, this._storage);

  // Login with phone or email
  Future<ApiResult<Map<String, dynamic>>> login({
    String? phone,
    String? email,
    required String password,
  }) async {
    try {
      final response = await _api.post('/auth/login', data: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'password': password,
        'loginType': 'password',
      });

      final data = response.data['data'] as Map<String, dynamic>;
      await _storage.saveTokens(data['token'] as String, data['refreshToken'] as String);
      await _storage.saveUser(data['user'] as Map<String, dynamic>);

      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Register
  Future<ApiResult<Map<String, dynamic>>> register({
    String? phone,
    String? email,
    required String password,
    String? inviteCode,
    required String captcha,
  }) async {
    try {
      final response = await _api.post('/auth/register', data: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'password': password,
        'inviteCode': inviteCode,
        'captcha': captcha,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      await _storage.saveTokens(data['token'] as String, data['refreshToken'] as String);
      await _storage.saveUser(data['user'] as Map<String, dynamic>);

      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Send verification code
  Future<ApiResult<bool>> sendCode({
    String? phone,
    String? email,
    required String type,
  }) async {
    try {
      final response = await _api.post('/auth/send-code', data: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'type': type,
      });
      return ApiResult.success(response.data['data']['sent'] as bool);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Reset password
  Future<ApiResult<bool>> resetPassword({
    String? phone,
    String? email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _api.post('/auth/reset-password', data: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'code': code,
        'newPassword': newPassword,
      });
      return ApiResult.success(response.data['data']['success'] as bool);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _storage.clearAuth();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }

  // Get current user
  User? getCurrentUser() {
    final userData = _storage.getUser();
    if (userData != null) return User.fromJson(userData);
    return null;
  }
}
