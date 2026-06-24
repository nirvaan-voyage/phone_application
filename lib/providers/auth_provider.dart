import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
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
    String identifier, {
    String? name,
    int? age,
    String? phone,
    bool rememberMe = false,
  }) async {
    final trimmedIdentifier = identifier.trim();
    final nextState = AuthState(
      isLoggedIn: true,
      userEmail: trimmedIdentifier.contains('@') ? trimmedIdentifier : null,
      loginId: trimmedIdentifier,
      name: name,
      age: age,
      phone: phone,
    );

    state = nextState;
    await _saveSession(nextState, rememberMe);
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
