import 'dart:convert';
import 'package:http/http.dart' as http;

/// Shared response parsing for all API modules.
class ApiHttpHelpers {
  ApiHttpHelpers._();

  static const Map<String, dynamic> connectionError = {
    'success': false,
    'message': 'Unable to reach the server. Check your connection and IP.',
  };

  static Map<String, dynamic> failureFromResponse(
    http.Response response,
    String fallback,
  ) {
    final data = jsonDecode(response.body);
    final detail = data is Map ? (data['detail'] ?? fallback) : fallback;
    return {'success': false, 'message': detail};
  }
}
