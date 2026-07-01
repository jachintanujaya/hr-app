import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

/// Firebase Auth manages access/refresh tokens natively, so this class is
/// now only responsible for caching the user profile for offline reads.
/// The saveTokens / getAccessToken / clearTokens methods are kept as no-ops
/// so nothing else in the codebase needs to change.
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearCache();

  // No-ops — Firebase Auth owns token lifecycle.
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> cacheUser(UserModel user) async {
    await secureStorage.write(
      key: StorageKeys.cachedUser,
      value: jsonEncode(user.toJson()),
    );
  }

  @override
  Future<UserModel> getCachedUser() async {
    final jsonStr = await secureStorage.read(key: StorageKeys.cachedUser);
    if (jsonStr == null) throw CacheException('No cached user found');
    return UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  @override
  Future<void> clearCache() async {
    await secureStorage.delete(key: StorageKeys.cachedUser);
  }

  // ── token stubs (Firebase handles these) ─────────────────────────────────

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<void> clearTokens() async {}
}