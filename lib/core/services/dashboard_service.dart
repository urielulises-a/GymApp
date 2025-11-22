import 'attendance_service.dart';
import 'payments_service.dart';
import 'members_service.dart';
import 'subscriptions_service.dart';
import '../models/payment.dart';

/// Servicio especializado para métricas avanzadas del dashboard
/// Calcula todas las métricas usando SOLO los endpoints existentes
class DashboardService {
  final AttendanceService _attendanceService = AttendanceService();
  final PaymentsService _paymentsService = PaymentsService();
  final MembersService _membersService = MembersService();
  final SubscriptionsService _subscriptionsService = SubscriptionsService();

  /// Obtener asistencias de hoy
  Future<Map<String, dynamic>> getTodayAttendance() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final response = await _attendanceService.getAttendance(
        fromDate: startOfDay.toIso8601String(),
        toDate: endOfDay.toIso8601String(),
        limit: 1000,
      );

      final count = response.data?.length ?? 0;
      return {
        'count': count,
        'date': startOfDay.toIso8601String(),
      };
    } catch (e) {
      return {'count': 0};
    }
  }

  /// Obtener ingresos del mes actual
  Future<Map<String, dynamic>> getCurrentMonthRevenue() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final response = await _paymentsService.getPayments(
        fromDate: startOfMonth.toIso8601String(),
        toDate: endOfMonth.toIso8601String(),
        status: 'Completado',
        limit: 1000,
      );

      final payments = response.data ?? [];
      double total = 0;
      for (final payment in payments) {
        total += payment.amount;
      }

      return {
        'amount': total,
        'count': payments.length,
        'month': now.month,
        'year': now.year,
      };
    } catch (e) {
      return {'amount': 0, 'count': 0};
    }
  }

  /// Obtener comparación mes actual vs anterior
  Future<Map<String, dynamic>> getMonthComparison() async {
    try {
      final now = DateTime.now();

      // Mes actual
      final startOfCurrentMonth = DateTime(now.year, now.month, 1);
      final endOfCurrentMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Mes anterior
      final startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
      final endOfPreviousMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

      // Obtener datos en paralelo
      final results = await Future.wait([
        // Miembros mes actual
        _membersService.getMembers(
          fromDate: startOfCurrentMonth.toIso8601String(),
          toDate: endOfCurrentMonth.toIso8601String(),
          limit: 1000,
        ),
        // Miembros mes anterior
        _membersService.getMembers(
          fromDate: startOfPreviousMonth.toIso8601String(),
          toDate: endOfPreviousMonth.toIso8601String(),
          limit: 1000,
        ),
        // Pagos mes actual
        _paymentsService.getPayments(
          fromDate: startOfCurrentMonth.toIso8601String(),
          toDate: endOfCurrentMonth.toIso8601String(),
          status: 'Completado',
          limit: 1000,
        ),
        // Pagos mes anterior
        _paymentsService.getPayments(
          fromDate: startOfPreviousMonth.toIso8601String(),
          toDate: endOfPreviousMonth.toIso8601String(),
          status: 'Completado',
          limit: 1000,
        ),
      ]);

      final currentMembers = results[0].data?.length ?? 0;
      final previousMembers = results[1].data?.length ?? 0;

      final currentPayments = (results[2].data ?? []).cast<Payment>();
      final previousPayments = (results[3].data ?? []).cast<Payment>();

      double currentRevenue = 0;
      for (final payment in currentPayments) {
        currentRevenue += payment.amount;
      }

      double previousRevenue = 0;
      for (final payment in previousPayments) {
        previousRevenue += payment.amount;
      }

      return {
        'currentMonth': {
          'members': currentMembers,
          'revenue': currentRevenue,
        },
        'previousMonth': {
          'members': previousMembers,
          'revenue': previousRevenue,
        },
      };
    } catch (e) {
      return {
        'currentMonth': {'members': 0, 'revenue': 0},
        'previousMonth': {'members': 0, 'revenue': 0},
      };
    }
  }

  /// Obtener nuevos socios por mes (últimos N meses)
  Future<List<Map<String, dynamic>>> getNewMembersStats({int months = 6}) async {
    try {
      final now = DateTime.now();
      final List<Map<String, dynamic>> stats = [];

      for (int i = months - 1; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final startOfMonth = DateTime(month.year, month.month, 1);
        final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

        final response = await _membersService.getMembers(
          fromDate: startOfMonth.toIso8601String(),
          toDate: endOfMonth.toIso8601String(),
          limit: 1000,
        );

        final monthNames = [
          '',
          'Enero',
          'Febrero',
          'Marzo',
          'Abril',
          'Mayo',
          'Junio',
          'Julio',
          'Agosto',
          'Septiembre',
          'Octubre',
          'Noviembre',
          'Diciembre'
        ];

        stats.add({
          'month': monthNames[month.month],
          'count': response.data?.length ?? 0,
          'year': month.year,
        });
      }

      return stats;
    } catch (e) {
      return [];
    }
  }

  /// Obtener distribución de socios activos vs inactivos
  Future<Map<String, dynamic>> getMembersStatusDistribution() async {
    try {
      final response = await _membersService.getMembers(limit: 1000);
      final members = response.data ?? [];

      int active = 0;
      int inactive = 0;

      for (final member in members) {
        if (member.status == 'Activo') {
          active++;
        } else {
          inactive++;
        }
      }

      return {
        'active': active,
        'inactive': inactive,
        'total': members.length,
      };
    } catch (e) {
      return {'active': 0, 'inactive': 0, 'total': 0};
    }
  }

  /// Obtener estadísticas de renovaciones
  Future<Map<String, dynamic>> getRenewalsStats() async {
    try {
      final now = DateTime.now();

      // Mes actual
      final startOfCurrentMonth = DateTime(now.year, now.month, 1);
      final endOfCurrentMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Mes anterior
      final startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
      final endOfPreviousMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

      final results = await Future.wait([
        _subscriptionsService.getSubscriptions(
          fromDate: startOfCurrentMonth.toIso8601String(),
          toDate: endOfCurrentMonth.toIso8601String(),
          status: 'Activo',
          limit: 1000,
        ),
        _subscriptionsService.getSubscriptions(
          fromDate: startOfPreviousMonth.toIso8601String(),
          toDate: endOfPreviousMonth.toIso8601String(),
          status: 'Activo',
          limit: 1000,
        ),
        _membersService.getMembers(limit: 1000),
      ]);

      final currentRenewals = results[0].data?.length ?? 0;
      final previousRenewals = results[1].data?.length ?? 0;
      final totalMembers = results[2].data?.length ?? 1;

      final rate = (currentRenewals / totalMembers) * 100;

      return {
        'thisMonth': currentRenewals,
        'lastMonth': previousRenewals,
        'rate': rate,
      };
    } catch (e) {
      return {'thisMonth': 0, 'lastMonth': 0, 'rate': 0.0};
    }
  }

  /// Obtener pagos por categoría/método
  Future<List<Map<String, dynamic>>> getPaymentsByCategory() async {
    try {
      final response = await _paymentsService.getPayments(
        status: 'Completado',
        limit: 1000,
      );

      final payments = response.data ?? [];
      final Map<String, Map<String, dynamic>> categoryMap = {};

      for (final payment in payments) {
        final method = payment.method;
        if (!categoryMap.containsKey(method)) {
          categoryMap[method] = {
            'method': method,
            'total': 0.0,
            'count': 0,
          };
        }
        categoryMap[method]!['total'] =
            (categoryMap[method]!['total'] as double) + payment.amount;
        categoryMap[method]!['count'] =
            (categoryMap[method]!['count'] as int) + 1;
      }

      return categoryMap.values.toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener tendencias de ingresos
  Future<Map<String, dynamic>> getRevenueTrends({int months = 6}) async {
    try {
      final now = DateTime.now();

      // Mes actual
      final startOfCurrentMonth = DateTime(now.year, now.month, 1);
      final endOfCurrentMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Mes anterior
      final startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
      final endOfPreviousMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

      final results = await Future.wait([
        _paymentsService.getPayments(
          fromDate: startOfCurrentMonth.toIso8601String(),
          toDate: endOfCurrentMonth.toIso8601String(),
          status: 'Completado',
          limit: 1000,
        ),
        _paymentsService.getPayments(
          fromDate: startOfPreviousMonth.toIso8601String(),
          toDate: endOfPreviousMonth.toIso8601String(),
          status: 'Completado',
          limit: 1000,
        ),
      ]);

      final currentPayments = (results[0].data ?? []).cast<Payment>();
      final previousPayments = (results[1].data ?? []).cast<Payment>();

      double currentRevenue = 0;
      for (final payment in currentPayments) {
        currentRevenue += payment.amount;
      }

      double previousRevenue = 0;
      for (final payment in previousPayments) {
        previousRevenue += payment.amount;
      }

      return {
        'currentMonth': currentRevenue,
        'previousMonth': previousRevenue,
      };
    } catch (e) {
      return {'currentMonth': 0, 'previousMonth': 0};
    }
  }

  /// Obtener duración promedio de sesiones
  Future<Map<String, dynamic>> getAverageSessionDuration() async {
    try {
      final response = await _attendanceService.getAttendance(
        status: 'Completado',
        limit: 1000,
      );

      final attendances = response.data ?? [];
      int totalMinutes = 0;
      int validSessions = 0;

      for (final attendance in attendances) {
        final checkIn = attendance.checkInTime;
        final checkOut = attendance.checkOutTime;

        if (checkIn != null && checkIn.isNotEmpty &&
            checkOut != null && checkOut.isNotEmpty) {
          final checkInDate = DateTime.parse(checkIn);
          final checkOutDate = DateTime.parse(checkOut);
          final duration = checkOutDate.difference(checkInDate).inMinutes;

          if (duration > 0 && duration < 600) {
            // Solo sesiones válidas (menos de 10 horas)
            totalMinutes += duration;
            validSessions++;
          }
        }
      }

      final average = validSessions > 0 ? totalMinutes / validSessions : 0;

      return {
        'average': average,
        'totalSessions': validSessions,
      };
    } catch (e) {
      return {'average': 0, 'totalSessions': 0};
    }
  }

  /// Obtener días de mayor afluencia
  Future<List<Map<String, dynamic>>> getTopAttendanceDays({int limit = 7}) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final response = await _attendanceService.getAttendance(
        fromDate: thirtyDaysAgo.toIso8601String(),
        toDate: now.toIso8601String(),
        limit: 1000,
      );

      final attendances = response.data ?? [];
      final Map<String, int> dailyCount = {};

      for (final attendance in attendances) {
        final checkIn = attendance.checkInTime;
        if (checkIn != null && checkIn.isNotEmpty) {
          final date = DateTime.parse(checkIn);
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

          dailyCount[dateKey] = (dailyCount[dateKey] ?? 0) + 1;
        }
      }

      final sortedDays = dailyCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedDays.take(limit).map((entry) {
        return {
          'date': entry.key,
          'count': entry.value,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener horas pico
  Future<Map<String, dynamic>> getPeakHours({
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final response = await _attendanceService.getAttendance(
        fromDate: fromDate,
        toDate: toDate,
        limit: 1000,
      );

      final attendances = response.data ?? [];
      final Map<String, Map<int, int>> hoursByDay = {
        'Lunes': {},
        'Martes': {},
        'Miércoles': {},
        'Jueves': {},
        'Viernes': {},
        'Sábado': {},
        'Domingo': {},
      };

      final dayNames = [
        '',
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo'
      ];

      for (final attendance in attendances) {
        final checkIn = attendance.checkInTime;
        if (checkIn != null && checkIn.isNotEmpty) {
          final date = DateTime.parse(checkIn);
          final dayName = dayNames[date.weekday];
          final hour = date.hour;

          hoursByDay[dayName]![hour] = (hoursByDay[dayName]![hour] ?? 0) + 1;
        }
      }

      final List<Map<String, dynamic>> peakHoursList = [];

      for (final entry in hoursByDay.entries) {
        if (entry.value.isNotEmpty) {
          final peakEntry = entry.value.entries.reduce(
            (a, b) => a.value > b.value ? a : b,
          );

          peakHoursList.add({
            'day': entry.key,
            'peakHour': '${peakEntry.key}:00',
            'count': peakEntry.value,
          });
        }
      }

      return {'days': peakHoursList};
    } catch (e) {
      return {'days': []};
    }
  }
}
