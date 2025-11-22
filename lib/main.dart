import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializar servicios
  await StorageService().init();

  // Inicializar formato de fechas
  await initializeDateFormatting('es_MX', null);

  runApp(const GymApp());
}
