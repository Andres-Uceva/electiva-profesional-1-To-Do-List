/// Excepción base para errores de API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Excepción para errores de red
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Excepción para timeout
class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Excepción para errores del servidor (5xx)
class ServerException implements Exception {
  final String message;
  final int statusCode;

  ServerException(this.message, this.statusCode);

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Excepción para errores del cliente (4xx)
class ClientException implements Exception {
  final String message;
  final int statusCode;

  ClientException(this.message, this.statusCode);

  @override
  String toString() => 'ClientException: $message (Status: $statusCode)';
}
