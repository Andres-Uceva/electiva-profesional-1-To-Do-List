import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/api_exception.dart';

/// Cliente HTTP para comunicarse con la API REST
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Realiza una petición GET
  Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      final response = await _client
          .get(uri, headers: ApiConstants.headers)
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet');
    } on TimeoutException {
      throw TimeoutException('La petición tardó demasiado tiempo');
    } catch (e) {
      throw ApiException('Error inesperado: $e');
    }
  }

  /// Realiza una petición POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      final response = await _client
          .post(
            uri,
            headers: ApiConstants.headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet');
    } on TimeoutException {
      throw TimeoutException('La petición tardó demasiado tiempo');
    } catch (e) {
      throw ApiException('Error inesperado: $e');
    }
  }

  /// Realiza una petición PUT
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      final response = await _client
          .put(
            uri,
            headers: ApiConstants.headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet');
    } on TimeoutException {
      throw TimeoutException('La petición tardó demasiado tiempo');
    } catch (e) {
      throw ApiException('Error inesperado: $e');
    }
  }

  /// Realiza una petición DELETE
  Future<void> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      
      final response = await _client
          .delete(uri, headers: ApiConstants.headers)
          .timeout(ApiConstants.connectionTimeout);

      _handleResponse(response);
    } on SocketException {
      throw NetworkException('No hay conexión a internet');
    } on TimeoutException {
      throw TimeoutException('La petición tardó demasiado tiempo');
    } catch (e) {
      throw ApiException('Error inesperado: $e');
    }
  }

  /// Maneja la respuesta HTTP y lanza excepciones apropiadas
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Respuesta exitosa
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      // Error del cliente (4xx)
      throw ClientException(
        'Error del cliente: ${response.body}',
        response.statusCode,
      );
    } else if (response.statusCode >= 500) {
      // Error del servidor (5xx)
      throw ServerException(
        'Error del servidor: ${response.body}',
        response.statusCode,
      );
    } else {
      throw ApiException(
        'Respuesta inesperada: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Cierra el cliente HTTP
  void dispose() {
    _client.close();
  }
}