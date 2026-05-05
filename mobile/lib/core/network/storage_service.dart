import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../config/app_config.dart';

/// Storage Service for managing local storage
class StorageService {
  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;
  late Directory _cacheDir;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    _cacheDir = await getApplicationCacheDirectory();
  }

  // Secure Storage
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConfig.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: AppConfig.accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConfig.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: AppConfig.refreshTokenKey);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([saveAccessToken(accessToken), saveRefreshToken(refreshToken)]);
  }

  Future<void> clearAuth() async {
    await Future.wait([
      _secureStorage.delete(key: AppConfig.accessTokenKey),
      _secureStorage.delete(key: AppConfig.refreshTokenKey),
      _prefs.remove(AppConfig.userKey),
    ]);
  }

  // User Data
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(AppConfig.userKey, jsonEncode(user));
  }

  Map<String, dynamic>? getUser() {
    final userStr = _prefs.getString(AppConfig.userKey);
    if (userStr != null) return jsonDecode(userStr) as Map<String, dynamic>;
    return null;
  }

  Future<void> clearUser() async => await _prefs.remove(AppConfig.userKey);

  // Settings
  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(AppConfig.languageKey, languageCode);
  }

  String getLanguage() => _prefs.getString(AppConfig.languageKey) ?? 'zh-CN';

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(AppConfig.themeKey, themeMode);
  }

  String getThemeMode() => _prefs.getString(AppConfig.themeKey) ?? 'system';

  // Reading Progress
  Future<void> saveReadingProgress(String bookId, Map<String, dynamic> progress) async {
    await _prefs.setString('${AppConfig.readingProgressKey}_$bookId', jsonEncode(progress));
  }

  Map<String, dynamic>? getReadingProgress(String bookId) {
    final progressStr = _prefs.getString('${AppConfig.readingProgressKey}_$bookId');
    if (progressStr != null) return jsonDecode(progressStr) as Map<String, dynamic>;
    return null;
  }

  Map<String, Map<String, dynamic>> getAllReadingProgress() {
    final progress = <String, Map<String, dynamic>>{};
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(AppConfig.readingProgressKey)) {
        final progressStr = _prefs.getString(key);
        if (progressStr != null) {
          final bookId = key.replaceFirst('${AppConfig.readingProgressKey}_', '');
          progress[bookId] = jsonDecode(progressStr) as Map<String, dynamic>;
        }
      }
    }
    return progress;
  }

  Future<void> clearReadingProgress(String bookId) async {
    await _prefs.remove('${AppConfig.readingProgressKey}_$bookId');
  }

  // Cache
  Future<void> saveCache(String key, dynamic data, {Duration? duration}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'duration': duration?.inMilliseconds ?? AppConfig.cacheDuration.inMilliseconds,
    };
    await _prefs.setString('${AppConfig.cacheKey}_$key', jsonEncode(cacheData));
  }

  dynamic getCache(String key) {
    final cacheStr = _prefs.getString('${AppConfig.cacheKey}_$key');
    if (cacheStr != null) {
      try {
        final cacheData = jsonDecode(cacheStr) as Map<String, dynamic>;
        final timestamp = cacheData['timestamp'] as int;
        final duration = cacheData['duration'] as int;
        if (DateTime.now().millisecondsSinceEpoch - timestamp < duration) {
          return cacheData['data'];
        } else {
          _prefs.remove('${AppConfig.cacheKey}_$key');
        }
      } catch (e) {
        if (kDebugMode) print('Error reading cache: $e');
      }
    }
    return null;
  }

  Future<void> clearCache() async {
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(AppConfig.cacheKey)) await _prefs.remove(key);
    }
  }

  Directory get cacheDirectory => _cacheDir;

  Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }

  Future<void> setString(String key, String value) async => await _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);
  Future<void> setInt(String key, int value) async => await _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);
  Future<void> setBool(String key, bool value) async => await _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);
  Future<void> remove(String key) async => await _prefs.remove(key);
  bool containsKey(String key) => _prefs.containsKey(key);
}
