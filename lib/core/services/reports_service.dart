import '../config/api_config.dart';
import 'http_service.dart';

// Servicio de reportes
class ReportsService {
  final HttpService _http = HttpService();

  // Obtener resumen de reportes
  Future<Map<String, dynamic>> getSummary() async {
    final response = await _http.get<Map<String, dynamic>>(
      '${ApiConfig.reportsEndpoint}/summary',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response.data ?? {};
  }

  // Exportar reporte a CSV
  Future<String> exportCsv({
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (fromDate != null) queryParams['fromDate'] = fromDate;
    if (toDate != null) queryParams['toDate'] = toDate;

    final response = await _http.get<String>(
      '${ApiConfig.reportsEndpoint}/export-csv',
      queryParams: queryParams,
      fromJson: (json) => json.toString(),
    );

    return response.data ?? '';
  }

  // Exportar reporte a PDF (base64)
  Future<String> exportPdf({
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (fromDate != null) queryParams['fromDate'] = fromDate;
    if (toDate != null) queryParams['toDate'] = toDate;

    final response = await _http.get<Map<String, dynamic>>(
      '${ApiConfig.reportsEndpoint}/export-pdf',
      queryParams: queryParams,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response.data?['pdf'] ?? '';
  }
}
