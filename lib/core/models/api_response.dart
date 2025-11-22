// Modelo genérico para respuestas del API
class ApiResponse<T> {
  final T? data;
  final ApiMeta? meta;
  final List<ApiError>? errors;

  ApiResponse({
    this.data,
    this.meta,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      meta: json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null,
      errors: json['errors'] != null
          ? (json['errors'] as List)
              .map((e) => ApiError.fromJson(e))
              .toList()
          : null,
    );
  }

  bool get hasErrors => errors != null && errors!.isNotEmpty;
  bool get isSuccess => !hasErrors;
}

class ApiMeta {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  ApiMeta({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
    );
  }
}

class ApiError {
  final String? message;
  final String? field;
  final String? code;

  ApiError({
    this.message,
    this.field,
    this.code,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'],
      field: json['field'],
      code: json['code'],
    );
  }
}
