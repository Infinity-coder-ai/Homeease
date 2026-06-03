import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';

/// Handles secure auth-token storage and refresh-token rotation for the app.
///
/// Access tokens stay short-lived, so this service also knows how to inspect
/// JWT expiry and exchange a refresh token for a new access token when needed.
class AuthSessionService {
  AuthSessionService._();

  static const _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  static const _leewaySeconds = 60;

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  static Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static DateTime? _jwtExpiry(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    final jsonMap = jsonDecode(decoded) as Map<String, dynamic>;
    final exp = jsonMap['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
  }

  /// Exposes the decoded JWT expiry so callers can schedule refreshes.
  static DateTime? tokenExpiry(String token) => _jwtExpiry(token);

  static bool isExpiredOrNearExpiry(String token) {
    final expiry = _jwtExpiry(token);
    if (expiry == null) return true;
    final cutoff = DateTime.now().toUtc().add(const Duration(seconds: _leewaySeconds));
    return !expiry.isAfter(cutoff);
  }

  static Future<String?> getValidAccessToken() async {
    final accessToken = await readAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;

    if (!isExpiredOrNearExpiry(accessToken)) {
      return accessToken;
    }

    return refreshAccessToken();
  }

  static Future<String?> refreshAccessToken() async {
    final refreshToken = await readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access_token']?.toString() ?? '';
        final newRefreshToken = data['refresh_token']?.toString() ?? '';
        if (newAccessToken.isNotEmpty && newRefreshToken.isNotEmpty) {
          await saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
          return newAccessToken;
        }
      }
    } catch (_) {
      // If refresh fails, the caller can decide whether to force logout.
    }

    return null;
  }

  static Future<void> revokeAndClearTokens() async {
    final refreshToken = await readRefreshToken();
    await clearTokens();

    if (refreshToken == null || refreshToken.isEmpty) return;

    // Best-effort revocation only; never block the UI from leaving the session.
    unawaited(() async {
      try {
        await http
            .post(
              Uri.parse('${ApiService.baseUrl}/auth/logout'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'refresh_token': refreshToken}),
            )
            .timeout(const Duration(seconds: 15));
      } catch (_) {
        // Logout should still complete locally even if the network is down.
      }
    }());
  }
}
