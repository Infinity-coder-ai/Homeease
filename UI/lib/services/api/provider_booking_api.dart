import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

/// Provider-side booking list and status updates.
class ProviderBookingApi {

  // ---------------------------------------------------------------
  // PROVIDER BOOKINGS
  // Backend endpoint: GET /providers/bookings
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getProviderBookings({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/providers/bookings'),
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
        final detail = data['detail'] ?? 'Failed to fetch provider bookings';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // PROVIDER BOOKING STATUS (Accept)
  // Backend endpoint: PATCH /bookings/{booking_id}/accept
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> acceptBooking({
    required String token,
    required int bookingId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId/accept'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to accept booking';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // PROVIDER BOOKING STATUS (Complete)
  // Backend endpoint: PATCH /bookings/{booking_id}/complete
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> completeBooking({
    required String token,
    required int bookingId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId/complete'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to complete booking';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }
}
