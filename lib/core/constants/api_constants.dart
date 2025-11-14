/// Constantes para la configuración de la API
class ApiConstants {
  // URL base de la API
  // Para Android Emulator: http://10.0.2.2:3000
  // Para dispositivo físico IP de tu computadora: http://192.168.x.x:3000
  // Para iOS Simulator: http://localhost:3000
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  // Endpoints
  static const String tasksEndpoint = '/tasks';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}