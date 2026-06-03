/// Central API exports and legacy [ApiService] facade.
///
/// HTTP implementations live under [api/] (one file per domain).
library;

import 'api/api_config.dart';
import 'api/auth_api.dart';
import 'api/support_api.dart';
import 'api/catalog_api.dart';
import 'api/booking_api.dart';
import 'api/provider_onboarding_api.dart';
import 'api/provider_ops_api.dart';
import 'api/provider_booking_api.dart';
import 'api/notifications_api.dart';
import 'api/admin_requests_api.dart';
import 'api/admin_providers_api.dart';

/// Legacy static entry point — delegates to domain API classes.
class ApiService {
  ApiService._();

  static const String baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> getProviders({
    required String token,
    String? status,
    String? city,
    double? minRating,
  }) async =>
      AdminProvidersApi.getProviders(token: token, status: status, city: city, minRating: minRating);

  static Future<Map<String, dynamic>> getProviderDetails({
    required String token,
    required int providerId,
  }) async =>
      AdminProvidersApi.getProviderDetails(token: token, providerId: providerId);

  static Future<Map<String, dynamic>> getProviderRatings({
    required String token,
    required int providerId,
  }) async =>
      AdminProvidersApi.getProviderRatings(token: token, providerId: providerId);

  static Future<Map<String, dynamic>> deactivateProvider({
    required String token,
    required int providerId,
  }) async =>
      AdminProvidersApi.deactivateProvider(token: token, providerId: providerId);

  static Future<Map<String, dynamic>> assignProviderRole({
    required String token,
    required int providerId,
  }) async =>
      AdminProvidersApi.assignProviderRole(token: token, providerId: providerId);

  static Future<Map<String, dynamic>> getProviderRequests({
    required String token,
  }) async =>
      AdminRequestsApi.getProviderRequests(token: token);

  static Future<Map<String, dynamic>> getSupportReports({
    required String token,
  }) async =>
      AdminRequestsApi.getSupportReports(token: token);

  static Future<Map<String, dynamic>> approveProviderRequest({
    required String token,
    required int providerId,
  }) async =>
      AdminRequestsApi.approveProviderRequest(token: token, providerId: providerId);

  static Future<Map<String, dynamic>> rejectProviderRequest({
    required String token,
    required int providerId,
  }) async =>
      AdminRequestsApi.rejectProviderRequest(token: token, providerId: providerId);

  static Future<Map<String, dynamic>> approveProviderDocument({
    required String token,
    required int providerId,
    required int documentId,
  }) async =>
      AdminRequestsApi.approveProviderDocument(token: token, providerId: providerId, documentId: documentId);

  static Future<Map<String, dynamic>> rejectProviderDocument({
    required String token,
    required int providerId,
    required int documentId,
  }) async =>
      AdminRequestsApi.rejectProviderDocument(token: token, providerId: providerId, documentId: documentId);

  static Future<Map<String, dynamic>> getProviderRequestDocuments({
    required String token,
    required int providerId,
  }) async =>
      AdminRequestsApi.getProviderRequestDocuments(token: token, providerId: providerId);

  static Future<Map<String, dynamic>> signup({  // with static we can directly call it using class name Apiservice
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async =>
      AuthApi.signup(name: name, email: email, password: password, phone: phone);

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async =>
      AuthApi.login(email: email, password: password);

  static Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
  }) async =>
      AuthApi.sendEmailOtp(email: email);

  static Future<Map<String, dynamic>> resendSignupOtp({
    required String email,
  }) async =>
      AuthApi.resendSignupOtp(email: email);

  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async =>
      AuthApi.verifyEmailOtp(email: email, otp: otp);

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async =>
      AuthApi.forgotPassword(email: email);

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async =>
      AuthApi.resetPassword(token: token, newPassword: newPassword);

  static Future<Map<String, dynamic>> getMe({
    required String token,
  }) async =>
      AuthApi.getMe(token: token);

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
  }) async =>
      BookingApi.createBooking(token: token, providerId: providerId, serviceId: serviceId, bookingDate: bookingDate, startTime: startTime, endTime: endTime, address: address, city: city, pincode: pincode, landmark: landmark);

  static Future<Map<String, dynamic>> getMyBookings({
    required String token,
  }) async =>
      BookingApi.getMyBookings(token: token);

  static Future<Map<String, dynamic>> cancelBooking({
    required String token,
    required int bookingId,
  }) async =>
      BookingApi.cancelBooking(token: token, bookingId: bookingId);

  static Future<Map<String, dynamic>> submitRating({
    required String token,
    required int bookingId,
    required int rating,
    String? review,
  }) async =>
      BookingApi.submitRating(token: token, bookingId: bookingId, rating: rating, review: review);

  static Future<Map<String, dynamic>> searchProviders({
    required int serviceId,
    required String token,
    String? city,
    String? area,
  }) async =>
      CatalogApi.searchProviders(serviceId: serviceId, token: token, city: city, area: area);

  static Future<Map<String, dynamic>> getNotifications({
    required String token,
    bool unreadOnly = false,
    int limit = 50,
    int offset = 0,
  }) async =>
      NotificationApi.getNotifications(token: token, unreadOnly: unreadOnly, limit: limit, offset: offset);

  static Future<Map<String, dynamic>> getUnreadNotificationsCount({
    required String token,
  }) async =>
      NotificationApi.getUnreadNotificationsCount(token: token);

  static Future<Map<String, dynamic>> markNotificationRead({
    required String token,
    required int id,
  }) async =>
      NotificationApi.markNotificationRead(token: token, id: id);

  static Future<Map<String, dynamic>> markAllNotificationsRead({
    required String token,
  }) async =>
      NotificationApi.markAllNotificationsRead(token: token);

  static Future<Map<String, dynamic>> getProviderBookings({
    required String token,
  }) async =>
      ProviderBookingApi.getProviderBookings(token: token);

  static Future<Map<String, dynamic>> acceptBooking({
    required String token,
    required int bookingId,
  }) async =>
      ProviderBookingApi.acceptBooking(token: token, bookingId: bookingId);

  static Future<Map<String, dynamic>> completeBooking({
    required String token,
    required int bookingId,
  }) async =>
      ProviderBookingApi.completeBooking(token: token, bookingId: bookingId);

  static Future<Map<String, dynamic>> createProviderProfile({
    required String token,
    required int experienceYears,
    required String city,
    required String area,
    required String pincode,
  }) async =>
      ProviderOnboardingApi.createProviderProfile(token: token, experienceYears: experienceYears, city: city, area: area, pincode: pincode);

  static Future<Map<String, dynamic>> createProviderService({
    required String token,
    required int serviceId,
    required double price,
    int? estimatedDurationMinutes,
  }) async =>
      ProviderOnboardingApi.createProviderService(token: token, serviceId: serviceId, price: price, estimatedDurationMinutes: estimatedDurationMinutes);

  static Future<Map<String, dynamic>> createProviderAvailability({
    required String token,
    required List<Map<String, dynamic>> slots,
  }) async =>
      ProviderOnboardingApi.createProviderAvailability(token: token, slots: slots);

  static Future<Map<String, dynamic>> uploadProviderDocument({
    required String token,
    required String documentType,
    required String filePath,
  }) async =>
      ProviderOnboardingApi.uploadProviderDocument(token: token, documentType: documentType, filePath: filePath);

  static Future<Map<String, dynamic>> getProviderServices({
    required String token,
  }) async =>
      ProviderOpsApi.getProviderServices(token: token);

  static Future<Map<String, dynamic>> deleteProviderService({
    required String token,
    required int serviceId,
  }) async =>
      ProviderOpsApi.deleteProviderService(token: token, serviceId: serviceId);

  static Future<Map<String, dynamic>> getProviderAvailability({
    required String token,
  }) async =>
      ProviderOpsApi.getProviderAvailability(token: token);

  static Future<Map<String, dynamic>> deleteProviderAvailability({
    required String token,
    required int slotId,
  }) async =>
      ProviderOpsApi.deleteProviderAvailability(token: token, slotId: slotId);

  static Future<Map<String, dynamic>> getProviderDocuments({
    required String token,
  }) async =>
      ProviderOpsApi.getProviderDocuments(token: token);

  static Future<Map<String, dynamic>> getProviderApplicationStatus({
    required String token,
  }) async =>
      ProviderOpsApi.getProviderApplicationStatus(token: token);

  static Future<Map<String, dynamic>> getProviderStats({
    required String token,
  }) async =>
      ProviderOpsApi.getProviderStats(token: token);

  static Future<Map<String, dynamic>> submitSupportReport({
    required String token,
    required String description,
  }) async =>
      SupportApi.submitSupportReport(token: token, description: description);

}

class ApiAuthService {
  ApiAuthService._();

  static Future<Map<String, dynamic>> signup({  // with static we can directly call it using class name Apiservice
    required String name,
    required String email,
    required String password,
    required String phone,
  }) =>
      AuthApi.signup(name: name, email: email, password: password, phone: phone);
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      AuthApi.login(email: email, password: password);
  static Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
  }) =>
      AuthApi.sendEmailOtp(email: email);
  static Future<Map<String, dynamic>> resendSignupOtp({
    required String email,
  }) =>
      AuthApi.resendSignupOtp(email: email);
  static Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) =>
      AuthApi.verifyEmailOtp(email: email, otp: otp);
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) =>
      AuthApi.forgotPassword(email: email);
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) =>
      AuthApi.resetPassword(token: token, newPassword: newPassword);
  static Future<Map<String, dynamic>> getMe({
    required String token,
  }) =>
      AuthApi.getMe(token: token);
}

class ApiCatalogService {
  ApiCatalogService._();

  static Future<Map<String, dynamic>> getServiceCatalog() =>
      CatalogApi.getServiceCatalog();

  static Future<Map<String, dynamic>> searchProviders({
    required int serviceId,
    required String token,
    String? city,
    String? area,
  }) =>
      CatalogApi.searchProviders(serviceId: serviceId, token: token, city: city, area: area);
}

class ApiBookingService {
  ApiBookingService._();

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
  }) =>
      BookingApi.createBooking(token: token, providerId: providerId, serviceId: serviceId, bookingDate: bookingDate, startTime: startTime, endTime: endTime, address: address, city: city, pincode: pincode, landmark: landmark);
  static Future<Map<String, dynamic>> getMyBookings({
    required String token,
  }) =>
      BookingApi.getMyBookings(token: token);
  static Future<Map<String, dynamic>> cancelBooking({
    required String token,
    required int bookingId,
  }) =>
      BookingApi.cancelBooking(token: token, bookingId: bookingId);
  static Future<Map<String, dynamic>> submitRating({
    required String token,
    required int bookingId,
    required int rating,
    String? review,
  }) =>
      BookingApi.submitRating(token: token, bookingId: bookingId, rating: rating, review: review);
}

class ApiProviderService {
  ApiProviderService._();

  static Future<Map<String, dynamic>> cancelBooking({
    required String token,
    required int bookingId,
  }) =>
      BookingApi.cancelBooking(token: token, bookingId: bookingId);
  static Future<Map<String, dynamic>> getProviderBookings({
    required String token,
  }) =>
      ProviderBookingApi.getProviderBookings(token: token);
  static Future<Map<String, dynamic>> acceptBooking({
    required String token,
    required int bookingId,
  }) =>
      ProviderBookingApi.acceptBooking(token: token, bookingId: bookingId);
  static Future<Map<String, dynamic>> completeBooking({
    required String token,
    required int bookingId,
  }) =>
      ProviderBookingApi.completeBooking(token: token, bookingId: bookingId);
  static Future<Map<String, dynamic>> createProviderProfile({
    required String token,
    required int experienceYears,
    required String city,
    required String area,
    required String pincode,
  }) =>
      ProviderOnboardingApi.createProviderProfile(token: token, experienceYears: experienceYears, city: city, area: area, pincode: pincode);
  static Future<Map<String, dynamic>> createProviderService({
    required String token,
    required int serviceId,
    required double price,
    int? estimatedDurationMinutes,
  }) =>
      ProviderOnboardingApi.createProviderService(token: token, serviceId: serviceId, price: price, estimatedDurationMinutes: estimatedDurationMinutes);
  static Future<Map<String, dynamic>> createProviderAvailability({
    required String token,
    required List<Map<String, dynamic>> slots,
  }) =>
      ProviderOnboardingApi.createProviderAvailability(token: token, slots: slots);
  static Future<Map<String, dynamic>> uploadProviderDocument({
    required String token,
    required String documentType,
    required String filePath,
  }) =>
      ProviderOnboardingApi.uploadProviderDocument(token: token, documentType: documentType, filePath: filePath);
  static Future<Map<String, dynamic>> getProviderServices({
    required String token,
  }) =>
      ProviderOpsApi.getProviderServices(token: token);
  static Future<Map<String, dynamic>> deleteProviderService({
    required String token,
    required int serviceId,
  }) =>
      ProviderOpsApi.deleteProviderService(token: token, serviceId: serviceId);
  static Future<Map<String, dynamic>> getProviderAvailability({
    required String token,
  }) =>
      ProviderOpsApi.getProviderAvailability(token: token);
  static Future<Map<String, dynamic>> deleteProviderAvailability({
    required String token,
    required int slotId,
  }) =>
      ProviderOpsApi.deleteProviderAvailability(token: token, slotId: slotId);
  static Future<Map<String, dynamic>> getProviderDocuments({
    required String token,
  }) =>
      ProviderOpsApi.getProviderDocuments(token: token);
  static Future<Map<String, dynamic>> getProviderApplicationStatus({
    required String token,
  }) =>
      ProviderOpsApi.getProviderApplicationStatus(token: token);
  static Future<Map<String, dynamic>> getProviderStats({
    required String token,
  }) =>
      ProviderOpsApi.getProviderStats(token: token);
}