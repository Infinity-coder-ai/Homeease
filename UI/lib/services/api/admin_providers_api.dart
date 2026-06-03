import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

/// Admin — approved provider directory
class AdminProvidersApi {
  // ---------------------------------------------------------------
  // ADMIN: Providers List (approved/rejected/pending)
  // Backend endpoint: GET /admin/providers
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviders({
    required String token,
    String? status,
    String? city,
    double? minRating,
  }) async {
    try {
      final params = <String, String>{};
      if (status != null && status.isNotEmpty) {
        params['status'] = status;
      }
      if (city != null && city.isNotEmpty) {
        params['city'] = city;
      }
      if (minRating != null) {
        params['min_rating'] = minRating.toString();
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/admin/providers')
          .replace(queryParameters: params.isEmpty ? null : params);
      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to load providers';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // ADMIN: Provider Details
  // Backend endpoint: GET /admin/providers/{provider_id}/details
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviderDetails({
    required String token,
    required int providerId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/providers/$providerId/details'),
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
        final detail = data['detail'] ?? 'Failed to load provider details';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // ADMIN: Provider Ratings
  // Backend endpoint: GET /admin/providers/{provider_id}/ratings
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviderRatings({
    required String token,
    required int providerId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/providers/$providerId/ratings'),
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
        final detail = data['detail'] ?? 'Failed to load provider ratings';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // ADMIN: Deactivate Provider
  // Backend endpoint: PATCH /admin/providers/{provider_id}/deactivate
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> deactivateProvider({
    required String token,
    required int providerId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/admin/providers/$providerId/deactivate'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to deactivate provider';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // ADMIN: Assign Provider Role (final approval step)
  // Backend endpoint: PATCH /admin/providers/{provider_id}/assign-role
  // Only callable after background verification is APPROVED.
  // Sets user.role = "provider" -- unlocks the provider dashboard.
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> assignProviderRole({
    required String token,
    required int providerId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/admin/providers/$providerId/assign-role'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to assign provider role';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }
}
