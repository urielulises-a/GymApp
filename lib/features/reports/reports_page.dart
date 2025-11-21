import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/utils/dates.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/export_utils.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/kpi_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = {
      'Ingresos Totales': MoneyFormatter.format(125000.0),
      'Socios Activos': '${kMembers.where((m) => m.status == 'Activo').length}',
      'Asistencia Promedio': '78.5%',
      'Renovaciones': '85.2%',
    };

    return AppScaffold(
      title: 'Reportes y Estadísticas',
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          tooltip: 'Exportar CSV',
          onPressed: () => _exportReports(context, summary),
        ),
        IconButton(
          icon: const Icon(Icons.print),
          tooltip: 'Imprimir',
          onPressed: () => _printReports(summary),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPIs Section
            Text(
              'Métricas Principales',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                KpiCard(
                  title: 'Ingresos Totales',
                  value: MoneyFormatter.format(125000.0),
                  subtitle: 'Últimos 30 días',
                  icon: Icons.attach_money_outlined,
                ),
                KpiCard(
                  title: 'Socios Activos',
                  value:
                      '${kMembers.where((m) => m.status == 'Activo').length}',
                  subtitle: 'Miembros activos',
                  icon: Icons.person_outlined,
                ),
                KpiCard(
                  title: 'Asistencia Promedio',
                  value: '78.5%',
                  subtitle: 'Últimos 30 días',
                  icon: Icons.trending_up_outlined,
                ),
                KpiCard(
                  title: 'Renovaciones',
                  value: '85.2%',
                  subtitle: 'Tasa de renovación',
                  icon: Icons.refresh_outlined,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Charts Section
            Text(
              'Análisis Detallado',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Revenue Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingresos por Mes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 150000,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    MoneyFormatter.format(value),
                                    style: theme.textTheme.bodySmall,
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = [
                                    'Ene',
                                    'Feb',
                                    'Mar',
                                    'Abr',
                                    'May',
                                    'Jun'
                                  ];
                                  return Text(
                                    months[value.toInt() % months.length],
                                    style: theme.textTheme.bodySmall,
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: true),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(
                                  toY: 100000, color: colorScheme.primary)
                            ]),
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(
                                  toY: 120000, color: colorScheme.primary)
                            ]),
                            BarChartGroupData(x: 2, barRods: [
                              BarChartRodData(
                                  toY: 110000, color: colorScheme.primary)
                            ]),
                            BarChartGroupData(x: 3, barRods: [
                              BarChartRodData(
                                  toY: 125000, color: colorScheme.primary)
                            ]),
                            BarChartGroupData(x: 4, barRods: [
                              BarChartRodData(
                                  toY: 130000, color: colorScheme.primary)
                            ]),
                            BarChartGroupData(x: 5, barRods: [
                              BarChartRodData(
                                  toY: 125000, color: colorScheme.primary)
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Member Growth Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crecimiento de Socios',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: theme.textTheme.bodySmall,
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = [
                                    'Ene',
                                    'Feb',
                                    'Mar',
                                    'Abr',
                                    'May',
                                    'Jun'
                                  ];
                                  return Text(
                                    months[value.toInt() % months.length],
                                    style: theme.textTheme.bodySmall,
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 120),
                                FlSpot(1, 135),
                                FlSpot(2, 142),
                                FlSpot(3, 148),
                                FlSpot(4, 156),
                                FlSpot(5, 156),
                              ],
                              isCurved: true,
                              color: colorScheme.secondary,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: colorScheme.secondary
                                    .withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Plan Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribución de Planes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: 45,
                              title: 'Básico\n45%',
                              color: colorScheme.primary,
                              radius: 60,
                              titleStyle: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 35,
                              title: 'Premium\n35%',
                              color: colorScheme.secondary,
                              radius: 60,
                              titleStyle: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 20,
                              title: 'VIP\n20%',
                              color: colorScheme.tertiary,
                              radius: 60,
                              titleStyle: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _exportReports(BuildContext context, Map<String, String> summary) {
  DataExporter.shareSummary(
    context: context,
    title: 'resumen-reportes',
    data: summary,
  );
}

Future<void> _printReports(Map<String, String> summary) async {
  await Printing.layoutPdf(
    onLayout: (format) async {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(32)),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Resumen de Reportes',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              ...summary.entries.map(
                (entry) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(entry.key,
                          style: const pw.TextStyle(fontSize: 14)),
                      pw.Text(entry.value,
                          style: const pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Generado el ${DateFormatter.formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );
      return doc.save();
    },
  );
}
