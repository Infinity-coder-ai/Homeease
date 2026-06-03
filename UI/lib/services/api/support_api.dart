import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

/// Support API endpoints.
class SupportApi {
// ---------------------------------------------------------------
  // SUPPORT REPORT
  // Backend endpoint: POST /support/reports
  // Requires: Authorization: Bearer <token>
  // Stores user-reported app problems in the database.
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> submitSupportReport({
    required String token,
    required String description,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/support/reports'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'description': description}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      }
      final detail = data['detail'] ?? 'Failed to submit report';
      return {'success': false, 'message': detail};
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }
}
