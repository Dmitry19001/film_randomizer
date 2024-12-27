// auth_state.dart
class AuthState {
  final String? username;
  final String? token;

  const AuthState({this.username, this.token});

  bool get isAuthenticated => username != null && token != null;

  AuthState copyWith({
    String? username,
    String? token,
  }) {
    return AuthState(
      username: username ?? this.username,
      token: token ?? this.token,
    );
  }

  factory AuthState.unauthenticated() =>
      const AuthState(username: null, token: null);
}
