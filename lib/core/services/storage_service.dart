import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

// Servicio para almacenamiento local
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Inicializar SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Guardar token
  Future<void> saveToken(String token) async {
    await init();
    await _prefs!.setString(ApiConfig.tokenKey, token);
  }

  // Obtener token
  Future<String?> getToken() async {
    await init();
    return _prefs!.getString(ApiConfig.tokenKey);
  }

  // Eliminar token
  Future<void> removeToken() async {
    await init();
    await _prefs!.remove(ApiConfig.tokenKey);
  }

  // Guardar usuario
  Future<void> saveUser(User user) async {
    await init();
    final userJson = jsonEncode(user.toJson());
    await _prefs!.setString(ApiConfig.userKey, userJson);
  }

  // Obtener usuario
  Future<User?> getUser() async {
    await init();
    final userJson = _prefs!.getString(ApiConfig.userKey);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  // Eliminar usuario
  Future<void> removeUser() async {
    await init();
    await _prefs!.remove(ApiConfig.userKey);
  }

  // Verificar si hay sesión activa
  Future<bool> hasSession() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && user != null;
  }

  // Limpiar toda la sesión
  Future<void> clearSession() async {
    await removeToken();
    await removeUser();
  }
}
