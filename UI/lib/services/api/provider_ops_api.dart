import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

/// Provider profile, services, availability, documents.
class ProviderOpsApi {
  // ---------------------------------------------------------------
  // PROVIDER SERVICES (List)
  // Backend endpoint: GET /providers/services
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviderServices({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/providers/services'),
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
        final detail = data['detail'] ?? 'Failed to fetch provider services';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // PROVIDER SERVICES (Delete)
  // Backend endpoint: DELETE /providers/services/{service_id}
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> deleteProviderService({
    required String token,
    required int serviceId,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/providers/services/$serviceId'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 204) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to delete service';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // PROVIDER AVAILABILITY (List)
  // Backend endpoint: GET /providers/availability
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviderAvailability({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/providers/availability'),
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
        final detail = data['detail'] ?? 'Failed to fetch availability';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // PROVIDER AVAILABILITY (Delete)
  // Backend endpoint: DELETE /providers/availability/{slot_id}
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> deleteProviderAvailability({
    required String token,
    required int slotId,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/providers/availability/$slotId'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 204) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to delete availability';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // PROVIDER DOCUMENTS (List)
  // Backend endpoint: GET /provider/documents
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviderDocuments({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/provider/documents'),
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
        final detail = data['detail'] ?? 'Failed to fetch documents';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // PROVIDER APPLICATION STATUS
  // Backend endpoint: GET /provider/application-status
  // Tracks profile submitted, document approval, and final admin approval.
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviderApplicationStatus({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/provider/application-status'),
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
        final detail = data['detail'] ?? 'Failed to load application status';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviderStats({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/providers/stats'),
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
        final detail = data['detail'] ?? 'Failed to fetch provider stats';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }


}
