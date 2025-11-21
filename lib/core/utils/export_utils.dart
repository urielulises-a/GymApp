import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DataExporter {
  const DataExporter._();

  static Future<void> copyAsCsv({
    required BuildContext context,
    required String fileName,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final csvBuffer = StringBuffer()
      ..writeln(headers.map(_escapeCsv).join(','));
    for (final row in rows) {
      csvBuffer.writeln(row.map(_escapeCsv).join(','));
    }

    await Clipboard.setData(ClipboardData(text: csvBuffer.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName exportado al portapapeles'),
          action: SnackBarAction(
            label: 'Pegar',
            onPressed: () async {
              final data = await Clipboard.getData('text/plain');
              if (data != null) {
                await Clipboard.setData(data);
              }
            },
          ),
        ),
      );
    }
  }

  static Future<void> shareSummary({
    required BuildContext context,
    required String title,
    required Map<String, String> data,
  }) async {
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final headers = ['Métrica', 'Valor'];
    final rows = data.entries.map((e) => [e.key, e.value]).toList();
    await copyAsCsv(
      context: context,
      fileName: '$title-$timestamp.csv',
      headers: headers,
      rows: rows,
    );
  }

  static String _escapeCsv(String value) {
    final needsQuotes =
        value.contains(',') || value.contains('"') || value.contains('\n');
    var sanitized = value.replaceAll('"', '""');
    if (needsQuotes) {
      sanitized = '"$sanitized"';
    }
    return sanitized;
  }
}
