import '../config/api_config.dart';
import '../models/user.dart';
import 'http_service.dart';
import 'storage_service.dart';

// Servicio de autenticación
class AuthService {
  final HttpService _http = HttpService();
  final StorageService _storage = StorageService();

  // Login
  Future<AuthResponse> login(String email, String password) async {
    final response = await _http.post<Map<String, dynamic>>(
      ApiConfig.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.data == null) {
      throw Exception('No se recibieron datos del servidor');
    }

    final authResponse = AuthResponse.fromJson(response.data!);

    // Guardar token y usuario
    await _storage.saveToken(authResponse.token);
    await _storage.saveUser(authResponse.user);

    return authResponse;
  }

  // Register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    String role = 'staff',
  }) async {
    final response = await _http.post<Map<String, dynamic>>(
      ApiConfig.registerEndpoint,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.data == null) {
      throw Exception('No se recibieron datos del servidor');
    }

    final authResponse = AuthResponse.fromJson(response.data!);

    // Guardar token y usuario
    await _storage.saveToken(authResponse.token);
    await _storage.saveUser(authResponse.user);

    return authResponse;
  }

  // Forgot password
  Future<String> forgotPassword(String email) async {
    final response = await _http.post<Map<String, dynamic>>(
      ApiConfig.forgotPasswordEndpoint,
      body: {'email': email},
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response.data?['message'] ?? 'Correo enviado correctamente';
  }

  // Logout
  Future<void> logout() async {
    try {
      // Intentar hacer logout en el servidor
      await _http.post(ApiConfig.logoutEndpoint);
    } catch (e) {
      // Ignorar errores del servidor en logout
    } finally {
      // Siempre limpiar sesión local
      await _storage.clearSession();
    }
  }

  // Obtener usuario actual
  Future<User?> getCurrentUser() async {
    return await _storage.getUser();
  }

  // Verificar si hay sesión activa
  Future<bool> isAuthenticated() async {
    return await _storage.hasSession();
  }
}
