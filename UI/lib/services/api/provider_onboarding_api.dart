import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

/// Provider Onboarding API endpoints.
class ProviderOnboardingApi {
// ---------------------------------------------------------------
  // CREATE PROVIDER PROFILE
  // Backend endpoint: POST /create_provider
  // Body (JSON): ProviderCreate schema
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> createProviderProfile({
    required String token,
    required int experienceYears,
    required String city,
    required String area,
    required String pincode,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/create_provider'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'experience_years': experienceYears,
              'city': city,
              'area': area,
              'pincode': pincode,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to create provider profile';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // CREATE PROVIDER SERVICE
  // Backend endpoint: POST /create_services
  // Body (JSON): ProviderServiceCreate schema
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> createProviderService({
    required String token,
    required int serviceId,
    required double price,
    int? estimatedDurationMinutes,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/create_services'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'service_id': serviceId,
              'price': price,
              'estimated_duration_minutes': estimatedDurationMinutes,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to create provider service';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // CREATE PROVIDER AVAILABILITY
  // Backend endpoint: POST /providers/availability
  // Body (JSON): ProviderAvailabilityBulkCreate
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> createProviderAvailability({
    required String token,
    required List<Map<String, dynamic>> slots,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/providers/availability'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'slots': slots}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to add availability';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // UPLOAD PROVIDER DOCUMENT
  // Backend endpoint: POST /provider/documents
  // Body (multipart/form-data): document_type, file
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> uploadProviderDocument({
    required String token,
    required String documentType,
    required String filePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/provider/documents'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['document_type'] = documentType;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to upload document';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }
}
