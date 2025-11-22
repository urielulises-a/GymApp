import 'package:flutter_dotenv/flutter_dotenv.dart';

// Configuración de la API
class ApiConfig {
  // URL base de la API - lee del .env o usa valor por defecto
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  // Versión de la API
  static const String apiVersion = 'v1';

  // URL completa de la API
  static String get apiUrl => '$baseUrl/api/$apiVersion';

  // Timeout para las peticiones
  static const Duration timeout = Duration(seconds: 30);

  // Headers por defecto
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Endpoints de autenticación
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String logoutEndpoint = '/auth/logout';

  // Endpoints de módulos
  static const String membersEndpoint = '/members';
  static const String plansEndpoint = '/plans';
  static const String subscriptionsEndpoint = '/subscriptions';
  static const String paymentsEndpoint = '/payments';
  static const String attendanceEndpoint = '/attendance';
  static const String reportsEndpoint = '/reports';
  static const String settingsEndpoint = '/settings';
  static const String notificationsEndpoint = '/notifications';

  // Keys para SharedPreferences
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
