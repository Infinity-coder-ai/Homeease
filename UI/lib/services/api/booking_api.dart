import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

/// Booking API endpoints.
class BookingApi {
// ---------------------------------------------------------------
  // CREATE BOOKING
  // Backend endpoint: POST /bookings
  // Body (JSON): BookingCreate schema
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> createBooking({
    required String token,
    required int providerId,
    required int serviceId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required String address,
    required String city,
    required String pincode,
    String? landmark,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/bookings'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'provider_id': providerId,
              'service_id': serviceId,
              'booking_date': bookingDate,
              'start_time': startTime,
              'end_time': endTime,
              'address': address,
              'city': city,
              'pincode': pincode,
              'landmark': landmark,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        final detail = data['detail'] ?? 'Booking failed';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // MY BOOKINGS (Customer)
  // Backend endpoint: GET /bookings/my
  // Requires: Authorization: Bearer <token>
  // Returns: List of BookingHistory
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> getMyBookings({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/bookings/my'),
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
        final detail = data['detail'] ?? 'Failed to fetch bookings';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // PROVIDER BOOKING STATUS (Cancel)
  // Backend endpoint: PATCH /bookings/{booking_id}/cancel
  // Requires: Authorization: Bearer <token>
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> cancelBooking({
    required String token,
    required int bookingId,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId/cancel'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to cancel booking';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }

  // ---------------------------------------------------------------
  // RATING
  // Backend endpoint: POST /rating/{booking_id}
  // Requires: Authorization: Bearer <token>
  // Body: { rating, review }
  // ---------------------------------------------------------------
  static Future<Map<String, dynamic>> submitRating({
    required String token,
    required int bookingId,
    required int rating,
    String? review,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/rating/$bookingId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'rating': rating,
              'review': review,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        final detail = data['detail'] ?? 'Failed to submit rating';
        return {'success': false, 'message': detail};
      }
    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }
  }
}
