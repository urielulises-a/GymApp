import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/attendance.dart';
import 'http_service.dart';

// Servicio de asistencia
class AttendanceService {
  final HttpService _http = HttpService();

  // Listar asistencias con filtros y paginación
  Future<ApiResponse<List<Attendance>>> getAttendance({
    int page = 1,
    int limit = 10,
    String? memberId,
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
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (fromDate != null) {
      queryParams['fromDate'] = fromDate;
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate;
    }

    return await _http.get<List<Attendance>>(
      ApiConfig.attendanceEndpoint,
      queryParams: queryParams,
      fromJson: (json) =>
          (json as List).map((item) => Attendance.fromJson(item)).toList(),
    );
  }

  // Obtener asistencia por ID
  Future<Attendance> getAttendanceById(String id) async {
    final response = await _http.get<Attendance>(
      '${ApiConfig.attendanceEndpoint}/$id',
      fromJson: (json) => Attendance.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Asistencia no encontrada');
    }

    return response.data!;
  }

  // Check-in
  Future<Attendance> checkIn(String memberId) async {
    final response = await _http.post<Attendance>(
      '${ApiConfig.attendanceEndpoint}/check-in',
      body: {'memberId': memberId},
      fromJson: (json) => Attendance.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al registrar entrada');
    }

    return response.data!;
  }

  // Check-out
  Future<Attendance> checkOut(String attendanceId) async {
    final response = await _http.post<Attendance>(
      '${ApiConfig.attendanceEndpoint}/check-out/$attendanceId',
      fromJson: (json) => Attendance.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al registrar salida');
    }

    return response.data!;
  }

  // Crear asistencia manual
  Future<Attendance> createAttendance({
    required String memberId,
    required String checkInTime,
    String? checkOutTime,
    String status = 'En curso',
  }) async {
    final response = await _http.post<Attendance>(
      ApiConfig.attendanceEndpoint,
      body: {
        'memberId': memberId,
        'checkInTime': checkInTime,
        if (checkOutTime != null) 'checkOutTime': checkOutTime,
        'status': status,
      },
      fromJson: (json) => Attendance.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al crear asistencia');
    }

    return response.data!;
  }

  // Actualizar asistencia
  Future<Attendance> updateAttendance(
    String id, {
    String? checkInTime,
    String? checkOutTime,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (checkInTime != null) body['checkInTime'] = checkInTime;
    if (checkOutTime != null) body['checkOutTime'] = checkOutTime;
    if (status != null) body['status'] = status;

    final response = await _http.put<Attendance>(
      '${ApiConfig.attendanceEndpoint}/$id',
      body: body,
      fromJson: (json) => Attendance.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al actualizar asistencia');
    }

    return response.data!;
  }

  // Eliminar asistencia
  Future<void> deleteAttendance(String id) async {
    await _http.delete('${ApiConfig.attendanceEndpoint}/$id');
  }

  // Exportar asistencias a CSV
  Future<String> exportAttendance() async {
    final response = await _http.get<String>(
      '${ApiConfig.attendanceEndpoint}/export',
      fromJson: (json) => json.toString(),
    );
    return response.data ?? '';
  }
}
