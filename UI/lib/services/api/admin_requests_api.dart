import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

/// Admin — provider applications & documents
class AdminRequestsApi {
  // ---------------------------------------------------------------
  // ADMIN: Provider Requests (List)
  // Backend endpoint: GET /admin/provider-requests
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviderRequests({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/provider-requests'),
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
        final detail = data['detail'] ?? 'Failed to load provider requests';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // ADMIN: Support Reports (List)
  // Backend endpoint: GET /admin/support/reports
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getSupportReports({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/support/reports'),
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
        final detail = data['detail'] ?? 'Failed to load support reports';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // ADMIN: Approve Provider Request
  // Backend endpoint: PATCH /admin/provider-requests/{provider_id}/approve
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> approveProviderRequest({
    required String token,
    required int providerId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse(
                '${ApiConfig.baseUrl}/admin/provider-requests/$providerId/approve'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to approve provider';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // ADMIN: Reject Provider Request
  // Backend endpoint: PATCH /admin/provider-requests/{provider_id}/reject
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> rejectProviderRequest({
    required String token,
    required int providerId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse(
                '${ApiConfig.baseUrl}/admin/provider-requests/$providerId/reject'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to reject provider';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // ADMIN: Approve one provider document
  // Backend endpoint: PATCH /admin/provider-requests/{provider_id}/documents/{document_id}/approve
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> approveProviderDocument({
    required String token,
    required int providerId,
    required int documentId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.baseUrl}/admin/provider-requests/$providerId/documents/$documentId/approve',
            ),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to approve document';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // ADMIN: Reject one provider document
  // Backend endpoint: PATCH /admin/provider-requests/{provider_id}/documents/{document_id}/reject
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> rejectProviderDocument({
    required String token,
    required int providerId,
    required int documentId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.baseUrl}/admin/provider-requests/$providerId/documents/$documentId/reject',
            ),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to reject document';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // ADMIN: Provider Request Documents
  // Backend endpoint: GET /admin/provider-requests/{provider_id}/documents
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviderRequestDocuments({
    required String token,
    required int providerId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${ApiConfig.baseUrl}/admin/provider-requests/$providerId/documents'),
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
        final detail = data['detail'] ?? 'Failed to load documents';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }


}
