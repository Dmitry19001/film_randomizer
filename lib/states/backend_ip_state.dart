// backend_ip_state.dart
class BackendIPState {
  final String apiBaseUrl;

  const BackendIPState({
    required this.apiBaseUrl,
  });

  BackendIPState copyWith({
    String? apiBaseUrl,
  }) {
    return BackendIPState(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
    );
  }
}
