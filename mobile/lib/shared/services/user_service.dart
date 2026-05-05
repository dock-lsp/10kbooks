import '../../core/network/api_client.dart';
import '../../core/network/storage_service.dart';
import '../models/user_model.dart';
import '../models/book_model.dart';
import 'book_service.dart';

/// User Service
class UserService {
  final ApiClient _api;
  final StorageService _storage;

  UserService(this._api, this._storage);

  // Get current user profile
  Future<ApiResult<User>> getMe() async {
    try {
      final response = await _api.get('/users/me');
      final user = User.fromJson(response.data['data'] as Map<String, dynamic>);
      await _storage.saveUser(response.data['data'] as Map<String, dynamic>);
      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Update profile
  Future<ApiResult<User>> updateProfile({
    String? nickname,
    String? bio,
    String? language,
  }) async {
    try {
      final response = await _api.patch('/users/me', data: {
        if (nickname != null) 'nickname': nickname,
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

  // Upload avatar
  Future<ApiResult<String>> uploadAvatar(String filePath) async {
    try {
      final response = await _api.uploadFile(
        '/users/me/avatar',
        filePath: filePath,
        fileName: 'avatar.jpg',
      );
      return ApiResult.success(response.data['data']['url'] as String);
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

  // Get user profile
  Future<ApiResult<User>> getUserProfile(String userId) async {
    try {
      final response = await _api.get('/users/$userId');
      final user = User.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResult.success(user);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Follow user
  Future<ApiResult<bool>> follow(String userId) async {
    try {
      final response = await _api.post('/users/$userId/follow');
      return ApiResult.success(response.data['data']['following'] as bool);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Unfollow user
  Future<ApiResult<bool>> unfollow(String userId) async {
    try {
      final response = await _api.delete('/users/$userId/follow');
      return ApiResult.success(response.data['data']['following'] as bool);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get followers
  Future<ApiResult<Map<String, dynamic>>> getFollowers(
    String userId, {
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _api.get('/users/$userId/followers', queryParameters: {
        'page': page,
        'size': size,
      });
      return ApiResult.success(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get following
  Future<ApiResult<Map<String, dynamic>>> getFollowing(
    String userId, {
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _api.get('/users/$userId/following', queryParameters: {
        'page': page,
        'size': size,
      });
      return ApiResult.success(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Get author info
  Future<ApiResult<Author>> getAuthorProfile(String authorId) async {
    try {
      final response = await _api.get('/authors/$authorId');
      final author = Author.fromJson(response.data['data'] as Map<String, dynamic>);
      return ApiResult.success(author);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Follow user
  Future<void> followUser(String userId) async {
    try {
      await _api.post('/users/$userId/follow');
    } catch (_) {}
  }

  // Unfollow user
  Future<void> unfollowUser(String userId) async {
    try {
      await _api.delete('/users/$userId/follow');
    } catch (_) {}
  }

  // Get user's books
  Future<ApiResult<Map<String, dynamic>>> getUserBooks(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.get('/users/$userId/books', queryParameters: {
        'page': page,
        'size': pageSize,
      });
      return ApiResult.success(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // Search users
  Future<ApiResult<Map<String, dynamic>>> searchUsers(
    String keyword, {
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _api.get('/users/search', queryParameters: {
        'keyword': keyword,
        'page': page,
        'size': size,
      });
      return ApiResult.success(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
