import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/dates.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppScaffold(
      title: 'Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPIs Row
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                KpiCard(
                  title: 'Total Socios',
                  value: '${kDashboardKPIs['totalMembers']}',
                  subtitle: 'Miembros registrados',
                  icon: Icons.people_outlined,
                ),
                KpiCard(
                  title: 'Socios Activos',
                  value: '${kDashboardKPIs['activeMembers']}',
                  subtitle: 'Miembros activos',
                  icon: Icons.person_outlined,
                ),
                KpiCard(
                  title: 'Ingresos Mensuales',
                  value:
                      MoneyFormatter.format(kDashboardKPIs['monthlyRevenue']),
                  subtitle: 'Este mes',
                  icon: Icons.attach_money_outlined,
                ),
                KpiCard(
                  title: 'Asistencia Promedio',
                  value: '${kDashboardKPIs['averageAttendance']}%',
                  subtitle: 'Últimos 30 días',
                  icon: Icons.trending_up_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Charts Section
            Text(
              'Estadísticas',
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
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
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
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 100000),
                                FlSpot(1, 120000),
                                FlSpot(2, 110000),
                                FlSpot(3, 125000),
                                FlSpot(4, 130000),
                                FlSpot(5, 125000),
                              ],
                              isCurved: true,
                              color: colorScheme.primary,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
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

            // Members Chart
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
            const SizedBox(height: 16),

            // Recent Activity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actividad Reciente',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...kMembers.take(3).map((member) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(member.name),
                          subtitle: Text(
                              'Se unió el ${member.joinDate.day}/${member.joinDate.month}/${member.joinDate.year}'),
                          trailing: Chip(
                            label: Text(member.status),
                            backgroundColor: member.status == 'Activo'
                                ? colorScheme.primaryContainer
                                : colorScheme.errorContainer,
                            labelStyle: TextStyle(
                              color: member.status == 'Activo'
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
                            ),
                          ),
                        )),
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
