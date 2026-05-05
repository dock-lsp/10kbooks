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
    String? captcha,
  }) async {
    try {
      final response = await _api.post('/auth/login', data: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'password': password,
        'loginType': 'password',
        if (captcha != null) 'captcha': captcha,
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
    String? captcha,
  }) async {
    try {
      final response = await _api.post('/auth/register', data: {
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'password': password,
        if (inviteCode != null) 'inviteCode': inviteCode,
        if (captcha != null) 'captcha': captcha,
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

  // Refresh token
  Future<ApiResult<Map<String, dynamic>>> refreshToken(String refreshTokenStr) async {
    try {
      final response = await _api.post('/auth/refresh', data: {
        'refreshToken': refreshTokenStr,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      await _storage.saveTokens(data['token'] as String, data['refreshToken'] as String);

      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Update user profile
  Future<ApiResult<User>> updateProfile({
    String? nickname,
    String? avatar,
    String? bio,
    String? language,
  }) async {
    try {
      final response = await _api.patch('/users/me', data: {
        if (nickname != null) 'nickname': nickname,
        if (avatar != null) 'avatar': avatar,
        if (bio != null) 'bio': bio,
        if (language != null) 'language': language,
      });
      final user = User.fromJson(response.data['data'] as Map<String, dynamic>);
      await _storage.saveUser(response.data['data'] as Map<String, dynamic>);
      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Submit real name authentication
  Future<ApiResult<bool>> submitRealAuth({
    required String idCardType,
    required String idCardFront,
    required String idCardBack,
    String? handheldPhoto,
  }) async {
    try {
      final response = await _api.post('/users/real-auth', data: {
        'idCardType': idCardType,
        'idCardFront': idCardFront,
        'idCardBack': idCardBack,
        if (handheldPhoto != null) 'handheldPhoto': handheldPhoto,
      });
      return ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
