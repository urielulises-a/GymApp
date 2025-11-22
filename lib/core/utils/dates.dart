import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'es_MX');
  static final DateFormat _dateTimeFormat =
      DateFormat('dd/MM/yyyy HH:mm', 'es_MX');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'es_MX');

  // Parsear string ISO a DateTime
  static DateTime? parseISOString(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Formatear DateTime o String ISO a fecha legible
  static String formatDate(dynamic date) {
    if (date == null) return '';
    if (date is String) {
      final parsed = parseISOString(date);
      return parsed != null ? _dateFormat.format(parsed) : date;
    }
    if (date is DateTime) {
      return _dateFormat.format(date);
    }
    return '';
  }

  static String formatDateTime(dynamic dateTime) {
    if (dateTime == null) return '';
    if (dateTime is String) {
      final parsed = parseISOString(dateTime);
      return parsed != null ? _dateTimeFormat.format(parsed) : dateTime;
    }
    if (dateTime is DateTime) {
      return _dateTimeFormat.format(dateTime);
    }
    return '';
  }

  static String formatTime(dynamic time) {
    if (time == null) return '';
    if (time is String) {
      final parsed = parseISOString(time);
      return parsed != null ? _timeFormat.format(parsed) : time;
    }
    if (time is DateTime) {
      return _timeFormat.format(time);
    }
    return '';
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Ayer';
    } else if (difference < 7) {
      return 'Hace $difference días';
    } else {
      return _dateFormat.format(date);
    }
  }
}

class MoneyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }
}
