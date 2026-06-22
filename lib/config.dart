/// App-wide configuration.
///
/// [apiBaseUrl] points at the Dot Weaver backend. Override per build with:
///   flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com
/// For the Android emulator hitting a server on the host machine, use
/// http://10.0.2.2:8090 ; for the iOS simulator use http://127.0.0.1:8090 .
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  /// When false, the app never calls the backend (treated as fully offline).
  static bool get backendEnabled =>
      apiBaseUrl.isNotEmpty && !apiBaseUrl.contains('api.example.com');
}
