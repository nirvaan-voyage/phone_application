import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.age,
    required this.password,
  });

  final String name;
  final String username;
  final String email;
  final String phone;
  final int? age;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'age': age,
      'password': password,
    };
  }
}

class RegisteredUser {
  const RegisteredUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    this.age,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final int? age;

  factory RegisteredUser.fromJson(Map<String, dynamic> json) {
    return RegisteredUser(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      age: json['age'] as int?,
    );
  }
}

class RegisterResponse {
  const RegisterResponse({
    required this.token,
    required this.user,
  });

  final String token;
  final RegisteredUser user;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      token: json['token'] as String,
      user: RegisteredUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class AuthApiException implements Exception {
  const AuthApiException({
    required this.message,
    this.field,
    this.suggestions = const [],
  });

  final String message;
  final String? field;
  final List<String> suggestions;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
    this.baseUrl = const String.fromEnvironment(
      'NIRVAAN_API_URL',
      defaultValue: 'http://localhost:8080',
    ),
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _tokenKey = 'nirvaan_jwt';

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;
  final String baseUrl;

  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(
        message: body['message'] as String? ?? 'Registration failed',
        field: body['field'] as String?,
        suggestions: (body['suggestions'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(),
      );
    }

    final registerResponse = RegisterResponse.fromJson(body);
    await saveToken(registerResponse.token);
    return registerResponse;
  }

  Future<void> saveToken(String token) {
    return _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearToken() {
    return _secureStorage.delete(key: _tokenKey);
  }
}
