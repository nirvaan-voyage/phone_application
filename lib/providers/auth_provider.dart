import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({
    this.isLoggedIn = false,
    this.userEmail,
    this.name,
    this.age,
    this.phone,
  });

  final bool isLoggedIn;
  final String? userEmail;
  final String? name;
  final int? age;
  final String? phone;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void login(
    String email, {
    String? name,
    int? age,
    String? phone,
  }) {
    state = AuthState(
      isLoggedIn: true,
      userEmail: email,
      name: name,
      age: age,
      phone: phone,
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
