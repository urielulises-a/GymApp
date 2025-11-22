import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/payment.dart';
import 'http_service.dart';

// Servicio de pagos
class PaymentsService {
  final HttpService _http = HttpService();

  // Listar pagos con filtros y paginación
  Future<ApiResponse<List<Payment>>> getPayments({
    int page = 1,
    int limit = 10,
    String? memberId,
    String? subscriptionId,
    String? method,
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
    if (subscriptionId != null && subscriptionId.isNotEmpty) {
      queryParams['subscriptionId'] = subscriptionId;
    }
    if (method != null && method.isNotEmpty) {
      queryParams['method'] = method;
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

    return await _http.get<List<Payment>>(
      ApiConfig.paymentsEndpoint,
      queryParams: queryParams,
      fromJson: (json) =>
          (json as List).map((item) => Payment.fromJson(item)).toList(),
    );
  }

  // Obtener pago por ID
  Future<Payment> getPaymentById(String id) async {
    final response = await _http.get<Payment>(
      '${ApiConfig.paymentsEndpoint}/$id',
      fromJson: (json) => Payment.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Pago no encontrado');
    }

    return response.data!;
  }

  // Crear pago
  Future<Payment> createPayment({
    required String memberId,
    required String subscriptionId,
    required double amount,
    required String paymentDate,
    required String method,
    String status = 'Completado',
    String? notes,
  }) async {
    final response = await _http.post<Payment>(
      ApiConfig.paymentsEndpoint,
      body: {
        'memberId': memberId,
        'subscriptionId': subscriptionId,
        'amount': amount,
        'paymentDate': paymentDate,
        'method': method,
        'status': status,
        if (notes != null) 'notes': notes,
      },
      fromJson: (json) => Payment.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al crear pago');
    }

    return response.data!;
  }

  // Actualizar pago
  Future<Payment> updatePayment(
    String id, {
    double? amount,
    String? paymentDate,
    String? method,
    String? status,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (amount != null) body['amount'] = amount;
    if (paymentDate != null) body['paymentDate'] = paymentDate;
    if (method != null) body['method'] = method;
    if (status != null) body['status'] = status;
    if (notes != null) body['notes'] = notes;

    final response = await _http.put<Payment>(
      '${ApiConfig.paymentsEndpoint}/$id',
      body: body,
      fromJson: (json) => Payment.fromJson(json),
    );

    if (response.data == null) {
      throw Exception('Error al actualizar pago');
    }

    return response.data!;
  }

  // Eliminar pago
  Future<void> deletePayment(String id) async {
    await _http.delete('${ApiConfig.paymentsEndpoint}/$id');
  }

  // Obtener recibo de pago
  Future<String> getReceipt(String id) async {
    final response = await _http.get<Map<String, dynamic>>(
      '${ApiConfig.paymentsEndpoint}/$id/receipt',
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return response.data?['pdf'] ?? '';
  }

  // Exportar pagos a CSV
  Future<String> exportPayments() async {
    final response = await _http.get<String>(
      '${ApiConfig.paymentsEndpoint}/export',
      fromJson: (json) => json.toString(),
    );
    return response.data ?? '';
  }
}
