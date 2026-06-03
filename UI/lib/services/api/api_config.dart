/// Base URL for the FastAPI backend.
/// Update [baseUrl] with your PC IP (`ipconfig`) for physical devices.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://10.148.53.172:8000';
  // Emulator: http://10.0.2.2:8000
}
