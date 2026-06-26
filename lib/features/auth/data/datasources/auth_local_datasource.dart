import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearCache();

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
    await secureStorage.write(key: StorageKeys.cachedUser, value: jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel> getCachedUser() async {
    final jsonStr = await secureStorage.read(key: StorageKeys.cachedUser);
    if (jsonStr == null) {
      throw CacheException('No cached user found');
    }
    return UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  @override
  Future<void> clearCache() async {
    await secureStorage.delete(key: StorageKeys.cachedUser);
  }

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await secureStorage.write(key: StorageKeys.accessToken, value: accessToken);
    await secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() => secureStorage.read(key: StorageKeys.accessToken);

  @override
  Future<String?> getRefreshToken() => secureStorage.read(key: StorageKeys.refreshToken);

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: StorageKeys.accessToken);
    await secureStorage.delete(key: StorageKeys.refreshToken);
  }
}
