import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// ── Storage key constants ──────────────────────────────────────────────────
class _StorageKeys {
  _StorageKeys._();
  static const token = 'nirvaan_jwt';
  static const email = 'nirvaan_email';
  static const name = 'nirvaan_name';
  static const username = 'nirvaan_username';
  static const phone = 'nirvaan_phone';
  static const age = 'nirvaan_age';
  static const loginId = 'nirvaan_login_id';
}

// ── Backend base URL ───────────────────────────────────────────────────────
// Configure based on your testing environment:
//   - Android emulator:  http://10.0.2.2:8080
//   - iOS simulator:     http://localhost:8080
//   - Physical device via USB debugging: http://localhost:8080
//   - Physical device via WiFi: http://[YOUR_WIFI_IP]:8080
//   - Web/Desktop:       http://localhost:8080
//
// Current setup: Phone and PC on same WiFi network
// Using Windows machine IP address
const String _kBaseUrl = 'http://192.168.10.7:8080';

// ── AuthState ──────────────────────────────────────────────────────────────
/// Represents the full authentication state of the app.
/// isGuest = true means the user is browsing without an account.
/// isLoggedIn = true means the user has a valid JWT session.
class AuthState {
  const AuthState({
    this.isLoggedIn = false,
    this.isGuest = true,
    this.token,
    this.userEmail,
    this.name,
    this.username,
    this.age,
    this.phone,
    this.loginId,
    this.isLoading = false,
    this.error,
    this.rememberMe = false,
  });

  final bool isLoggedIn;
  final bool isGuest;
  final String? token;
  final String? userEmail;
  final String? name;
  final String? username;
  final int? age;
  final String? phone;
  final String? loginId;
  final bool isLoading;
  final String? error;
  final bool rememberMe;

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isGuest,
    String? token,
    String? userEmail,
    String? name,
    String? username,
    int? age,
    String? phone,
    String? loginId,
    bool? isLoading,
    String? error,
    bool? rememberMe,
    // Explicit nulls — pass clearError: true to wipe the error field
    bool clearError = false,
    bool clearToken = false,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuest: isGuest ?? this.isGuest,
      token: clearToken ? null : (token ?? this.token),
      userEmail: userEmail ?? this.userEmail,
      name: name ?? this.name,
      username: username ?? this.username,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      loginId: loginId ?? this.loginId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  /// Display name: prefer name, fall back to email prefix, then 'Traveller'.
  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    if (userEmail != null && userEmail!.isNotEmpty) {
      return userEmail!.split('@').first;
    }
    return 'Traveller';
  }
}

// ── AuthNotifier ───────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  late final FlutterSecureStorage _storage;

  // ── Session restoration ─────────────────────────────────────────────────
  /// Called once from SplashScreen. Restores JWT session if present,
  /// otherwise enters guest mode automatically.
  Future<void> restoreSession() async {
    try {
      final token = await _storage.read(key: _StorageKeys.token);
      if (token == null || token.isEmpty) {
        enterGuestMode();
        return;
      }

      final email = await _storage.read(key: _StorageKeys.email);
      final name = await _storage.read(key: _StorageKeys.name);
      final username = await _storage.read(key: _StorageKeys.username);
      final phone = await _storage.read(key: _StorageKeys.phone);
      final loginId = await _storage.read(key: _StorageKeys.loginId);
      final ageStr = await _storage.read(key: _StorageKeys.age);

      state = AuthState(
        isLoggedIn: true,
        isGuest: false,
        token: token,
        userEmail: email,
        name: name,
        username: username,
        phone: phone,
        loginId: loginId,
        age: ageStr != null ? int.tryParse(ageStr) : null,
        rememberMe: true,
      );
    } catch (e) {
      // If secure storage fails, fall back to guest mode
      debugPrint('[AuthNotifier] restoreSession error: $e');
      enterGuestMode();
    }
  }

  // ── Guest mode ──────────────────────────────────────────────────────────
  /// Allows browsing without an account. No credentials stored.
  void enterGuestMode() {
    state = const AuthState(isLoggedIn: false, isGuest: true);
  }

  // ── Registration ────────────────────────────────────────────────────────
  /// POST /auth/register
  /// Returns null on success, or an error message string on failure.
  Future<String?> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required int age,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await http
          .post(
            Uri.parse('$_kBaseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'username': username,
              'email': email,
              'phone': phone,
              'age': age,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registration succeeded — some backends auto-login and return a token
        final token = body['token'] as String?;
        if (token != null) {
          await persistAndApplySession(
            token: token,
            email: email,
            name: name,
            username: username,
            phone: phone,
            age: age,
          );
        } else {
          // No token on register — user should log in next
          state = state.copyWith(isLoading: false);
        }
        return null; // success
      } else {
        final msg = _extractErrorMessage(body);
        state = state.copyWith(isLoading: false, error: msg);
        return msg;
      }
    } catch (e) {
      final msg = 'Could not connect to server at $_kBaseUrl. '
          'Ensure backend is running and accessible.';
      state = state.copyWith(isLoading: false, error: msg);
      return msg;
    }
  }

  // ── Login ───────────────────────────────────────────────────────────────
  /// POST /auth/login
  /// emailOrUsername can be either the user's email, username, OR phone number.
  /// Returns null on success, or an error message string on failure.
  Future<String?> login({
    required String emailOrUsername,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await http
          .post(
            Uri.parse('$_kBaseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'emailOrUsername': emailOrUsername,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final token = body['token'] as String? ?? '';
        final user = body['user'] as Map<String, dynamic>? ?? {};

        final email = user['email'] as String? ?? emailOrUsername;
        final name = user['name'] as String?;
        final username = user['username'] as String?;
        final phone = user['phone'] as String?;
        final loginId = user['id']?.toString();
        final age = user['age'] is int
            ? user['age'] as int
            : int.tryParse(user['age']?.toString() ?? '');

        if (rememberMe) {
          await persistAndApplySession(
            token: token,
            email: email,
            name: name,
            username: username,
            phone: phone,
            age: age,
            loginId: loginId,
          );
        } else {
          // Session only — don't persist to storage
          state = AuthState(
            isLoggedIn: true,
            isGuest: false,
            token: token,
            userEmail: email,
            name: name,
            username: username,
            phone: phone,
            age: age,
            loginId: loginId,
            rememberMe: false,
          );
        }
        return null; // success
      } else {
        final msg = _extractErrorMessage(body);
        state = state.copyWith(isLoading: false, error: msg);
        return msg;
      }
    } catch (e) {
      final msg = 'Could not connect to server at $_kBaseUrl. '
          'Ensure backend is running and accessible.';
      state = state.copyWith(isLoading: false, error: msg);
      return msg;
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _clearStorage();
    state = const AuthState(isLoggedIn: false, isGuest: true);
  }

  // ── OTP & Password Reset ────────────────────────────────────────────────
  /// POST /auth/generate-otp
  /// purpose: 'signup' | 'forgot_password'
  /// Returns { 'otp': '123456' } in dev, or null on success (if sent via email).
  Future<String?> generateOtp(String email, String purpose) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await http.post(
        Uri.parse('$_kBaseUrl/auth/generate-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'purpose': purpose}),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      state = state.copyWith(isLoading: false);

      if (response.statusCode == 200) {
        // In dev, the OTP is returned in the body
        return body['otp']?.toString();
      } else {
        final msg = _extractErrorMessage(body);
        state = state.copyWith(error: msg);
        throw Exception(msg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// POST /auth/verify-otp
  Future<void> verifyOtp(String email, String purpose, String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await http.post(
        Uri.parse('$_kBaseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'purpose': purpose, 'code': code}),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      state = state.copyWith(isLoading: false);

      if (response.statusCode != 200) {
        final msg = _extractErrorMessage(body);
        state = state.copyWith(error: msg);
        throw Exception(msg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// POST /auth/reset-password
  Future<void> resetPassword(String email, String code, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await http.post(
        Uri.parse('$_kBaseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      state = state.copyWith(isLoading: false);

      if (response.statusCode != 200) {
        final msg = _extractErrorMessage(body);
        state = state.copyWith(error: msg);
        throw Exception(msg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // ── Auth gate helper ────────────────────────────────────────────────────
  /// Returns true if the user can access gated features.
  bool get isAuthenticated => state.isLoggedIn && state.token != null;

  // ── Private helpers ─────────────────────────────────────────────────────
  Future<void> persistAndApplySession({
    required String token,
    required String email,
    String? name,
    String? username,
    String? phone,
    int? age,
    String? loginId,
  }) async {
    await _storage.write(key: _StorageKeys.token, value: token);
    await _storage.write(key: _StorageKeys.email, value: email);
    if (name != null) await _storage.write(key: _StorageKeys.name, value: name);
    if (username != null) {
      await _storage.write(key: _StorageKeys.username, value: username);
    }
    if (phone != null) {
      await _storage.write(key: _StorageKeys.phone, value: phone);
    }
    if (age != null) {
      await _storage.write(key: _StorageKeys.age, value: age.toString());
    }
    if (loginId != null) {
      await _storage.write(key: _StorageKeys.loginId, value: loginId);
    }

    state = AuthState(
      isLoggedIn: true,
      isGuest: false,
      token: token,
      userEmail: email,
      name: name,
      username: username,
      phone: phone,
      age: age,
      loginId: loginId,
      rememberMe: true,
      isLoading: false,
    );
  }

  Future<void> _clearStorage() async {
    await _storage.delete(key: _StorageKeys.token);
    await _storage.delete(key: _StorageKeys.email);
    await _storage.delete(key: _StorageKeys.name);
    await _storage.delete(key: _StorageKeys.username);
    await _storage.delete(key: _StorageKeys.phone);
    await _storage.delete(key: _StorageKeys.age);
    await _storage.delete(key: _StorageKeys.loginId);
  }

  String _extractErrorMessage(Map<String, dynamic> body) {
    // Try common backend error field names
    return (body['error'] ??
            body['message'] ??
            body['msg'] ??
            'Something went wrong. Please try again.')
        .toString();
  }
}

// ── Provider ───────────────────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
