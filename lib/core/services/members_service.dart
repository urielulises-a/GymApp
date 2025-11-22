import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/member.dart';
import 'http_service.dart';

// Servicio de miembros
class MembersService {
  final HttpService _http = HttpService();

  // Listar miembros con filtros y paginación
  Future<ApiResponse<List<Member>>> getMembers({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? planId,
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

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (planId != null && planId.isNotEmpty) {
      queryParams['planId'] = planId;
    }
    if (fromDate != null) {
      queryParams['fromDate'] = fromDate;
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate;
    }

    return await _http.get<List<Member>>(
      ApiConfig.membersEndpoint,
      queryParams: queryParams,
      fromJson: (json) =>
          (json as List).map((item) => Member.fromJson(item)).toList(),
    );
  }

  // Obtener miembro por ID
  Future<Member> getMemberById(String id) async {
    final response = await _http.get<Member>(
      '${ApiConfig.membersEndpoint}/$id',
      fromJson: (json) => Member.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Miembro no encontrado');
    }

    return response.data!;
  }

  // Crear miembro
  Future<Member> createMember({
    required String name,
    required String email,
    String? phone,
    String? joinDate,
    String status = 'Activo',
    String? planId,
  }) async {
    final response = await _http.post<Member>(
      ApiConfig.membersEndpoint,
      body: {
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (joinDate != null) 'joinDate': joinDate,
        'status': status,
        if (planId != null) 'planId': planId,
      },
      fromJson: (json) => Member.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al crear miembro');
    }

    return response.data!;
  }

  // Actualizar miembro
  Future<Member> updateMember(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? joinDate,
    String? status,
    String? planId,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (joinDate != null) body['joinDate'] = joinDate;
    if (status != null) body['status'] = status;
    if (planId != null) body['planId'] = planId;

    final response = await _http.put<Member>(
      '${ApiConfig.membersEndpoint}/$id',
      body: body,
      fromJson: (json) => Member.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al actualizar miembro');
    }

    return response.data!;
  }

  // Eliminar miembro
  Future<void> deleteMember(String id) async {
    await _http.delete('${ApiConfig.membersEndpoint}/$id');
  }

  // Exportar miembros a CSV
  Future<String> exportMembers() async {
    final response = await _http.get<String>(
      '${ApiConfig.membersEndpoint}/export',
      fromJson: (json) => json.toString(),
    );
    return response.data ?? '';
  }
}
