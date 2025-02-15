import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ITokenService {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> setAccessToken(String accessToken);
  Future<void> setRefreshToken(String refreshToken);
  Future<void> clearTokens();
  Future<String?> refreshAccessToken(Dio client);
}


class TokenService implements ITokenService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refreshToken');
  }

  @override
  Future<void> setAccessToken(String accessToken) async {
    await _secureStorage.write(key: 'accessToken', value: accessToken);
  }

  @override
  Future<void> setRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
  }

  @override
  Future<String?> refreshAccessToken(Dio client) async {
    final String? refreshToken = await getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await client.get(
        'your_refresh_token_endpoint',
        queryParameters: {'token': refreshToken},
      );

      if (response.statusCode == 200) {
        final String? newAccessToken = response.data['accessToken'];
        if (newAccessToken != null) {
          await setAccessToken(newAccessToken);
          return newAccessToken;
        }
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        // Refresh token expired, clear tokens
        await clearTokens();
      }
    }
    return null;
  }
}