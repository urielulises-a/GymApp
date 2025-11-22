import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

// Excepciones personalizadas
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<ApiError>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

// Servicio HTTP base para todas las peticiones
class HttpService {
  final StorageService _storage = StorageService();

  // Obtener headers con token de autenticación
  Future<Map<String, String>> _getHeaders({Map<String, String>? extra}) async {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);

    // Agregar token si existe
    final token = await _storage.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Agregar headers extra
    if (extra != null) {
      headers.addAll(extra);
    }

    return headers;
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = await _getHeaders();

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders();

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders();

      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders();

      final response = await http
          .delete(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Construir URI con query params
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final url = '${ApiConfig.apiUrl}$endpoint';
    final uri = Uri.parse(url);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }

    return uri;
  }

  // Manejar respuesta HTTP
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final statusCode = response.statusCode;

    // Decodificar el body
    Map<String, dynamic> jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (e) {
      throw ApiException(
        'Error al decodificar respuesta del servidor',
        statusCode: statusCode,
      );
    }

    // Manejar códigos de error HTTP
    if (statusCode >= 400) {
      final errors = jsonBody['errors'] != null
          ? (jsonBody['errors'] as List)
              .map((e) => ApiError.fromJson(e))
              .toList()
          : null;

      final message = errors?.isNotEmpty == true
          ? errors!.first.message ?? 'Error desconocido'
          : jsonBody['message'] ?? 'Error en la petición';

      throw ApiException(
        message,
        statusCode: statusCode,
        errors: errors,
      );
    }

    // Retornar respuesta exitosa
    return ApiResponse<T>.fromJson(jsonBody, fromJson);
  }

  // Manejar errores
  ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    String message = 'Error de conexión con el servidor';

    if (error.toString().contains('SocketException')) {
      message = 'No hay conexión a internet';
    } else if (error.toString().contains('TimeoutException')) {
      message = 'Tiempo de espera agotado';
    } else if (error.toString().contains('FormatException')) {
      message = 'Error en el formato de datos';
    }

    return ApiException(message);
  }
}
