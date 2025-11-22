import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/plan.dart';
import 'http_service.dart';

// Servicio de planes
class PlansService {
  final HttpService _http = HttpService();

  // Listar planes con filtros y paginación
  Future<ApiResponse<List<Plan>>> getPlans({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'order': order,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    return await _http.get<List<Plan>>(
      ApiConfig.plansEndpoint,
      queryParams: queryParams,
      fromJson: (json) =>
          (json as List).map((item) => Plan.fromJson(item)).toList(),
    );
  }

  // Obtener plan por ID
  Future<Plan> getPlanById(String id) async {
    final response = await _http.get<Plan>(
      '${ApiConfig.plansEndpoint}/$id',
      fromJson: (json) => Plan.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Plan no encontrado');
    }

    return response.data!;
  }

  // Crear plan
  Future<Plan> createPlan({
    required String name,
    required String description,
    required double price,
    required int durationDays,
    List<String> features = const [],
    String status = 'Activo',
  }) async {
    final response = await _http.post<Plan>(
      ApiConfig.plansEndpoint,
      body: {
        'name': name,
        'description': description,
        'price': price,
        'durationDays': durationDays,
        'features': features,
        'status': status,
      },
      fromJson: (json) => Plan.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al crear plan');
    }

    return response.data!;
  }

  // Actualizar plan
  Future<Plan> updatePlan(
    String id, {
    String? name,
    String? description,
    double? price,
    int? durationDays,
    List<String>? features,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (price != null) body['price'] = price;
    if (durationDays != null) body['durationDays'] = durationDays;
    if (features != null) body['features'] = features;
    if (status != null) body['status'] = status;

    final response = await _http.put<Plan>(
      '${ApiConfig.plansEndpoint}/$id',
      body: body,
      fromJson: (json) => Plan.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al actualizar plan');
    }

    return response.data!;
  }

  // Eliminar plan
  Future<void> deletePlan(String id) async {
    await _http.delete('${ApiConfig.plansEndpoint}/$id');
  }
}
