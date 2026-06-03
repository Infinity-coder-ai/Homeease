import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

/// Catalog API endpoints.
class CatalogApi {
// ---------------------------------------------------------------
  // SEARCH PROVIDERS
  // Backend endpoint: GET /providers/search
  // Query params: service_id (required), city, area
  // Returns: List of { id, name, city, area, trust_score, total_jobs_completed }
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> searchProviders({
    required int serviceId,
    required String token,
    String? city,
    String? area,
  }) async {
    final params = <String, String>{
      'service_id': serviceId.toString(),
    };
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (area != null && area.isNotEmpty) params['area'] = area;

    final uri = Uri.parse('${ApiConfig.baseUrl}/providers/search').replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      final data = jsonDecode(response.body);
      final detail = data['detail'] ?? 'Failed to fetch providers';
      return {'success': false, 'message': detail};
    }
  }

  // ---------------------------------------------------------------
  // SERVICE CATALOG
  // Backend endpoint: GET /services_catalog
  // Returns: List of { id, name }
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getServiceCatalog() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/services_catalog'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to fetch services';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }
}
