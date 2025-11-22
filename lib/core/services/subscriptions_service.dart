import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/subscription.dart';
import 'http_service.dart';

// Servicio de suscripciones
class SubscriptionsService {
  final HttpService _http = HttpService();

  // Listar suscripciones con filtros y paginación
  Future<ApiResponse<List<Subscription>>> getSubscriptions({
    int page = 1,
    int limit = 10,
    String? memberId,
    String? planId,
    String? status,
    String? fromDate,
    String? toDate,
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'order': order,
    };

    if (memberId != null && memberId.isNotEmpty) {
      queryParams['memberId'] = memberId;
    }
    if (planId != null && planId.isNotEmpty) {
      queryParams['planId'] = planId;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (fromDate != null) {
      queryParams['fromDate'] = fromDate;
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate;
    }

    return await _http.get<List<Subscription>>(
      ApiConfig.subscriptionsEndpoint,
      queryParams: queryParams,
      fromJson: (json) =>
          (json as List).map((item) => Subscription.fromJson(item)).toList(),
    );
  }

  // Obtener suscripción por ID
  Future<Subscription> getSubscriptionById(String id) async {
    final response = await _http.get<Subscription>(
      '${ApiConfig.subscriptionsEndpoint}/$id',
      fromJson: (json) => Subscription.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Suscripción no encontrada');
    }

    return response.data!;
  }

  // Crear suscripción
  Future<Subscription> createSubscription({
    required String memberId,
    required String planId,
    required String startDate,
    String? status,
  }) async {
    final response = await _http.post<Subscription>(
      ApiConfig.subscriptionsEndpoint,
      body: {
        'memberId': memberId,
        'planId': planId,
        'startDate': startDate,
        if (status != null) 'status': status,
      },
      fromJson: (json) => Subscription.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al crear suscripción');
    }

    return response.data!;
  }

  // Actualizar suscripción
  Future<Subscription> updateSubscription(
    String id, {
    String? startDate,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (startDate != null) body['startDate'] = startDate;
    if (status != null) body['status'] = status;

    final response = await _http.put<Subscription>(
      '${ApiConfig.subscriptionsEndpoint}/$id',
      body: body,
      fromJson: (json) => Subscription.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al actualizar suscripción');
    }

    return response.data!;
  }

  // Eliminar suscripción
  Future<void> deleteSubscription(String id) async {
    await _http.delete('${ApiConfig.subscriptionsEndpoint}/$id');
  }

  // Exportar suscripciones a CSV
  Future<String> exportSubscriptions() async {
    final response = await _http.get<String>(
      '${ApiConfig.subscriptionsEndpoint}/export',
      fromJson: (json) => json.toString(),
    );
    return response.data ?? '';
  }
}
