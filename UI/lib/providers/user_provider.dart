import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_session_service.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────
// USER STATE
// Stores the logged-in user's info globally so any screen
// (Home, Bookings, Profile) can access it without constructor args.
// ─────────────────────────────────────────────────────────────────
class UserState {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? token;
  final bool providerMode;

  const UserState({
    this.id,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.role = 'customer',
    this.token,
    this.providerMode = false,
  });

  bool get isLoggedIn => token != null;
  bool get isProvider => role == 'provider';
}

// ─────────────────────────────────────────────────────────────────
// USER NOTIFIER
// Called once after login to store user info globally.
// No autoDispose — we want this to survive across screens.
// ─────────────────────────────────────────────────────────────────
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  Timer? _refreshTimer;
  int _sessionVersion = 0;

  static const _tokenKey = 'auth_token';
  static const _nameKey = 'user_name';
  static const _phoneKey = 'user_phone';
  static const _idKey = 'user_id';
  static const _emailKey = 'user_email';
  static const _roleKey = 'user_role';
  static const _providerModeKey = 'provider_mode';

  void setUser({required String name, required String token}) {
    state = UserState(
      name: name,
      token: token,
      role: state.role,
      email: state.email,
      phone: state.phone,
      id: state.id,
      providerMode: state.providerMode,
    );
  }

  void setProfile({
    required int id,
    required String name,
    required String email,
    String phone = '',
    required String role,
  }) {
    state = UserState(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      token: state.token,
      providerMode: state.providerMode,
    );
  }

  void setProviderMode(bool enabled) {
    state = UserState(
      id: state.id,
      name: state.name,
      email: state.email,
      phone: state.phone,
      role: state.role,
      token: state.token,
      providerMode: enabled,
    );
  }

  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  int _nextSessionVersion() {
    _sessionVersion += 1;
    return _sessionVersion;
  }

  void _scheduleRefresh(String accessToken) {
    final sessionVersion = _sessionVersion;
    _cancelRefreshTimer();

    final expiry = AuthSessionService.tokenExpiry(accessToken);
    if (expiry == null) return;

    // Refresh a little before expiry so the UI never sees a 401 if the app is active.
    final refreshAt = expiry.subtract(const Duration(minutes: 2));
    final delay = refreshAt.difference(DateTime.now().toUtc());
    _refreshTimer = Timer(delay.isNegative ? Duration.zero : delay, () async {
      if (sessionVersion != _sessionVersion) return;
      await ensureValidAccessToken();
    });
  }

  Future<void> persistUser({
    required String name,
    required String accessToken,
    required String refreshToken,
  }) async {
    final sessionVersion = _sessionVersion;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await AuthSessionService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    state = UserState(
      name: name,
      token: accessToken,
      role: state.role,
      email: state.email,
      phone: state.phone,
      id: state.id,
      providerMode: state.providerMode,
    );
    if (sessionVersion != _sessionVersion) return;
    _scheduleRefresh(accessToken);
  }

  Future<void> persistProfile({
    required int id,
    required String name,
    required String email,
    String phone = '',
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_idKey, id);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_roleKey, role);
  }

  Future<void> persistProviderMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_providerModeKey, enabled);
  }

  Future<void> loadFromPrefs() async {
    final sessionVersion = _sessionVersion;
    final prefs = await SharedPreferences.getInstance();
    var token = await AuthSessionService.readAccessToken();
    final refreshToken = await AuthSessionService.readRefreshToken();
    final legacyToken = prefs.getString(_tokenKey);
    final name = prefs.getString(_nameKey) ?? '';
    final email = prefs.getString(_emailKey) ?? '';
    final phone = prefs.getString(_phoneKey) ?? '';
    final role = prefs.getString(_roleKey) ?? 'customer';
    final providerMode = prefs.getBool(_providerModeKey) ?? false;
    final id = prefs.getInt(_idKey);
    String? resolvedToken = token;
    if ((resolvedToken == null || resolvedToken.isEmpty) && legacyToken != null && legacyToken.isNotEmpty) {
      resolvedToken = legacyToken;
      await AuthSessionService.saveAccessToken(legacyToken);
    }
    if ((resolvedToken == null || resolvedToken.isEmpty) && refreshToken != null && refreshToken.isNotEmpty) {
      resolvedToken = await AuthSessionService.refreshAccessToken();
    } else if (resolvedToken != null && resolvedToken.isNotEmpty && AuthSessionService.isExpiredOrNearExpiry(resolvedToken) && refreshToken != null && refreshToken.isNotEmpty) {
      resolvedToken = await AuthSessionService.refreshAccessToken() ?? resolvedToken;
    }

    if (sessionVersion != _sessionVersion) return;
    if (resolvedToken != null && resolvedToken.isNotEmpty) {
      state = UserState(
        id: id,
        name: name,
        email: email,
        phone: phone,
        role: role,
        token: resolvedToken,
        providerMode: providerMode,
      );
      _scheduleRefresh(resolvedToken);
    }
  }

  Future<String?> ensureValidAccessToken() async {
    final sessionVersion = _sessionVersion;
    final currentToken = state.token;
    if (currentToken != null && currentToken.isNotEmpty && !AuthSessionService.isExpiredOrNearExpiry(currentToken)) {
      return currentToken;
    }

    final refreshedToken = await AuthSessionService.refreshAccessToken();
    if (refreshedToken == null || refreshedToken.isEmpty) {
      return null;
    }

    if (sessionVersion != _sessionVersion) return null;

    state = UserState(
      id: state.id,
      name: state.name,
      email: state.email,
      phone: state.phone,
      role: state.role,
      token: refreshedToken,
      providerMode: state.providerMode,
    );
    _scheduleRefresh(refreshedToken);
    return refreshedToken;
  }

  Future<void> fetchMe() async {
    final sessionVersion = _sessionVersion;
    final token = await ensureValidAccessToken();
    if (token == null || token.isEmpty) return;

    final result = await ApiService.getMe(token: token);
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      final id = data['id'] as int?;
      final name = data['name']?.toString() ?? '';
      final email = data['email']?.toString() ?? '';
      final phone = data['phone']?.toString() ?? '';
      final role = data['role']?.toString() ?? 'customer';

      if (id != null) {
        if (sessionVersion != _sessionVersion) return;
        setProfile(id: id, name: name, email: email, phone: phone, role: role);
        await persistProfile(id: id, name: name, email: email, phone: phone, role: role);
        if (role != 'provider' && state.providerMode) {
          setProviderMode(false);
          await persistProviderMode(false);
        }
      }
    }
  }

  Future<void> logout() async {
    _nextSessionVersion();
    _cancelRefreshTimer();
    state = const UserState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_providerModeKey);
    await prefs.remove(_idKey);
    await AuthSessionService.revokeAndClearTokens();
  }
}

// ─────────────────────────────────────────────────────────────────
// PROVIDER
// NOT autoDispose — user state must persist across the whole app
// ─────────────────────────────────────────────────────────────────
//create a provider whose job is to expose state managed by a StateNotifier”
final userProvider = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(),
);


//autoDispose means Riverpod will automatically destroy that provider's state when nothing is using it anymore.