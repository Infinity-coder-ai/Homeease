import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

/// Auth API endpoints.
class AuthApi {
// ---------------------------------------------------------------
  // ---------------------------------------------------------------
  // SIGNUP
  // Backend endpoint: POST /auth/signup/start
  // Body (JSON): { name, email, password, phone }
  // Starts signup intent + sends OTP. Does NOT create users row yet.
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> signup({  // with static we can directly call it using class name Apiservice
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {              //async marks the function as one that can pause and resume.
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/signup/start'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'phone': phone,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body); //Converts the JSON response string from FastAPI into a Dart Map

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        // Backend returns {"detail": "..."} on error
        final detail = data['detail'] ?? 'Signup failed';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // LOGIN
  // Backend endpoint: POST /login
  // Body (form-data): username (= email), password
  // Returns: { access_token, token_type }
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/login'),
            // OAuth2PasswordRequestForm requires form-encoded body, NOT JSON
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body:
                'username=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}',
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'access_token': data['access_token'],
          'refresh_token': data['refresh_token'],
        };
      } else {
        final detail = data['detail'] ?? 'Login failed';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // EMAIL OTP (SIGNUP VERIFICATION)
  // Backend endpoints:
  //   POST /auth/signup/start   (JSON: { name, email, password, phone })
  //   POST /auth/signup/verify  (JSON: { email, otp })
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/email/otp/send'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      final detail = data['detail'] ?? 'Failed to send OTP';
      return {'success': false, 'message': detail};
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // RESEND SIGNUP OTP (INTENT-BASED SIGNUP)
  // Backend endpoint: POST /auth/signup/resend (JSON: { email })
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> resendSignupOtp({
    required String email,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/signup/resend'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      final detail = data['detail'] ?? 'Failed to resend OTP';
      return {'success': false, 'message': detail};
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/signup/verify'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      }
      final detail = data['detail'] ?? 'Failed to verify OTP';
      return {'success': false, 'message': detail};
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // FORGOT PASSWORD
  // Backend endpoint: POST /auth/password/forgot (JSON: { email })
  // Sends a secure reset link to email.
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/password/forgot'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      final detail = data['detail'] ?? 'Failed to start password reset';
      return {'success': false, 'message': detail};
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // RESET PASSWORD (IN-APP TOKEN ENTRY)
  // Backend endpoint: POST /auth/password/reset/confirm (JSON: { token, password })
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/password/reset/confirm'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token, 'password': newPassword}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      final detail = data['detail'] ?? 'Failed to reset password';
      return {'success': false, 'message': detail};
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // CURRENT USER
  // Backend endpoint: GET /users/me
  // Requires: Authorization: Bearer <token>
  // Returns: { id, name, email, role }
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getMe({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/users/me'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to fetch user profile';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }
}
