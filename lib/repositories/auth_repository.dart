import '../core/services/api_service.dart';

class AuthRepository {
  final ApiService _api = ApiService();

  /// LOGIN
  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    return await _api.post(
      "/auth/login",
      {
        "emailOrUsername": emailOrUsername,
        "password": password,
      },
    );
  }

  /// REGISTER
  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required int age,
    required String password,
  }) async {
    return await _api.post(
      "/auth/register",
      {
        "name": name,
        "username": username,
        "email": email,
        "phone": phone,
        "age": age,
        "password": password,
      },
    );
  }

  /// GENERATE OTP
  Future<Map<String, dynamic>> generateOTP({
    required String email,
    required String purpose,
  }) async {
    return await _api.post(
      "/auth/generate-otp",
      {
        "email": email,
        "purpose": purpose,
      },
    );
  }

  /// VERIFY OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String purpose,
    required String code,
  }) async {
    return await _api.post(
      "/auth/verify-otp",
      {
        "email": email,
        "purpose": purpose,
        "code": code,
      },
    );
  }

  /// RESET PASSWORD
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    return await _api.post(
      "/auth/reset-password",
      {
        "email": email,
        "code": code,
        "password": password,
      },
    );
  }
}
