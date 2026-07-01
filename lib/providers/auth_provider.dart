import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../core/services/secure_storage_service.dart';

class AuthState {
  const AuthState({
    this.isLoggedIn = false,
    this.userEmail,
    this.name,
    this.age,
    this.phone,
    this.loginId,
  });

  final bool isLoggedIn;
  final String? userEmail;
  final String? name;
  final int? age;
  final String? phone;
  final String? loginId;

  Map<String, dynamic> toJson() {
    return {
      'isLoggedIn': isLoggedIn,
      'userEmail': userEmail,
      'name': name,
      'age': age,
      'phone': phone,
      'loginId': loginId,
    };
  }

  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      isLoggedIn: json['isLoggedIn'] == true,
      userEmail: json['userEmail'] as String?,
      name: json['name'] as String?,
      age: json['age'] as int?,
      phone: json['phone'] as String?,
      loginId: json['loginId'] as String?,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository = AuthRepository();
  final SecureStorageService _secureStorage = SecureStorageService();
  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  File get _sessionFile {
    return File('${Directory.systemTemp.path}/nirvaan_auth_session.json');
  }

  Future<void> _restoreSession() async {
    try {
      final file = _sessionFile;
      if (!await file.exists()) return;
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      state = AuthState.fromJson(data);
    } catch (_) {
      state = const AuthState();
    }
  }

  Future<void> _saveSession(AuthState authState, bool rememberMe) async {
    try {
      final file = _sessionFile;
      if (!rememberMe) {
        if (await file.exists()) {
          await file.delete();
        }
        return;
      }
      await file.writeAsString(jsonEncode(authState.toJson()));
    } catch (_) {
      // The UI should still log in even if local persistence fails.
    }
  }

  Future<void> login(
    String identifier,
    String password, {
    bool rememberMe = false,
  }) async {
    final response = await _repository.login(
      emailOrUsername: identifier,
      password: password,
    );

    final user = response["user"];
    final token = response["token"] as String;

    await _secureStorage.saveToken(token);

    final nextState = AuthState(
      isLoggedIn: true,
      userEmail: user["email"],
      loginId: identifier,
      name: user["name"],
      age: user["age"],
      phone: user["phone"],
    );

    state = nextState;

    await _saveSession(nextState, rememberMe);
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required int age,
    required String password,
  }) async {
    final response = await _repository.register(
      name: name,
      username: username,
      email: email,
      phone: phone,
      age: age,
      password: password,
    );

    final user = response["user"];

    final nextState = AuthState(
      isLoggedIn: true,
      userEmail: user["email"],
      loginId: email,
      name: user["name"],
      age: user["age"],
      phone: user["phone"],
    );

    state = nextState;

    await _saveSession(nextState, true);
  }

  Future<void> socialLogin(String provider, {bool rememberMe = true}) async {
    final nextState = AuthState(
      isLoggedIn: true,
      userEmail: '${provider.toLowerCase()}@nirvaan.app',
      loginId: provider,
      name: provider,
    );

    state = nextState;
    await _saveSession(nextState, rememberMe);
  }

  Future<void> logout() async {
    await _secureStorage.deleteToken();

    state = const AuthState();

    try {
      final file = _sessionFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
