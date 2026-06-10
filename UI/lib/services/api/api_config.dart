/// Base URL for the FastAPI backend.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://homeease-qydw.onrender.com',
  );
  // Emulator: http://10.0.2.2:8000
}
