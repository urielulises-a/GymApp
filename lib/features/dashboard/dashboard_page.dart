import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/stats_card.dart';
import '../../core/utils/dates.dart';
import '../../core/services/reports_service.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/services/http_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _reportsService = ReportsService();
  final _dashboardService = DashboardService();

  Map<String, dynamic> _summary = {};
  Map<String, dynamic> _todayAttendance = {};
  Map<String, dynamic> _currentMonthRevenue = {};
  Map<String, dynamic> _monthComparison = {};
  List<Map<String, dynamic>> _newMembersStats = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar datos en paralelo para mejor rendimiento
      final results = await Future.wait([
        _reportsService.getSummary(),
        _dashboardService.getTodayAttendance(),
        _dashboardService.getCurrentMonthRevenue(),
        _dashboardService.getMonthComparison(),
        _dashboardService.getNewMembersStats(months: 6),
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as Map<String, dynamic>;
          _todayAttendance = results[1] as Map<String, dynamic>;
          _currentMonthRevenue = results[2] as Map<String, dynamic>;
          _monthComparison = results[3] as Map<String, dynamic>;
          _newMembersStats = results[4] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const AppScaffold(
        title: 'Dashboard',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Extraer datos del summary
    final revenue = _summary['revenue'] as Map<String, dynamic>? ?? {};
    final members = _summary['members'] as Map<String, dynamic>? ?? {};
    final planDistribution =
        _summary['planDistribution'] as List<dynamic>? ?? [];
    final recentPayments = _summary['recentPayments'] as List<dynamic>? ?? [];

    // Datos de revenue
    final monthlyRevenue = revenue['monthly'] as List<dynamic>? ?? [];

    // Datos de members
    final totalMembers = members['total'] ?? 0;
    final activeMembers = members['active'] ?? 0;
    final growth = members['growth'] ?? 0;

    // Datos de hoy
    final todayAttendanceCount = _todayAttendance['count'] ?? 0;
    final todayRevenueAmount = _currentMonthRevenue['amount'] ?? 0;

    // Comparación mes actual vs anterior
    final currentMonthMembers = _monthComparison['currentMonth']?['members'] ?? 0;
    final previousMonthMembers = _monthComparison['previousMonth']?['members'] ?? 0;
    final membersDiff = currentMonthMembers - previousMonthMembers;
    final membersTrend = membersDiff > 0 ? 'up' : (membersDiff < 0 ? 'down' : 'neutral');
    final membersTrendPercent = previousMonthMembers > 0
        ? ((membersDiff / previousMonthMembers) * 100).abs().toStringAsFixed(1)
        : '0.0';

    final currentMonthRevenue = _monthComparison['currentMonth']?['revenue'] ?? 0;
    final previousMonthRevenue = _monthComparison['previousMonth']?['revenue'] ?? 0;
    final revenueDiff = currentMonthRevenue - previousMonthRevenue;
    final revenueTrend = revenueDiff > 0 ? 'up' : (revenueDiff < 0 ? 'down' : 'neutral');
    final revenueTrendPercent = previousMonthRevenue > 0
        ? ((revenueDiff / previousMonthRevenue) * 100).abs().toStringAsFixed(1)
        : '0.0';

    return AppScaffold(
      title: 'Dashboard',
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDashboardData,
        tooltip: 'Actualizar',
        child: const Icon(Icons.refresh),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).padding.bottom + 150.0,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Panel de Control',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              DateFormatter.formatDate(DateTime.now()),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Métricas principales del día
              SectionHeader(
                title: 'Resumen de Hoy',
                subtitle: 'Actividad del día actual',
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 2 : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 1.45,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                  KpiCard(
                    title: 'Asistencias Hoy',
                    value: '$todayAttendanceCount',
                    subtitle: 'Registros del día',
                    icon: Icons.fitness_center,
                    color: Colors.blue,
                  ),
                  KpiCard(
                    title: 'Ingresos del Mes',
                    value: MoneyFormatter.format(todayRevenueAmount),
                    subtitle: 'Mes actual',
                    icon: Icons.monetization_on,
                    color: Colors.green,
                  ),
                  KpiCard(
                    title: 'Socios Activos',
                    value: '$activeMembers',
                    subtitle: 'Con suscripción vigente',
                    icon: Icons.people,
                    color: Colors.purple,
                    trend: growth > 0 ? 'up' : (growth < 0 ? 'down' : 'neutral'),
                    trendValue: growth > 0 ? '+$growth' : (growth < 0 ? '$growth' : '0'),
                  ),
                  KpiCard(
                    title: 'Total Socios',
                    value: '$totalMembers',
                    subtitle: 'Todos los miembros',
                    icon: Icons.group,
                    color: Colors.orange,
                  ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Comparación mes actual vs anterior
              SectionHeader(
                title: 'Comparativa Mensual',
                subtitle: 'Mes actual vs anterior',
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return Row(
                      children: [
                        Expanded(
                          child: TrendCard(
                            title: 'Nuevos Socios',
                            currentValue: '$currentMonthMembers',
                            previousValue: '$previousMonthMembers',
                            trend: membersTrend,
                            trendPercentage: '$membersTrendPercent%',
                            icon: Icons.person_add,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TrendCard(
                            title: 'Ingresos',
                            currentValue: MoneyFormatter.format(currentMonthRevenue),
                            previousValue: MoneyFormatter.format(previousMonthRevenue),
                            trend: revenueTrend,
                            trendPercentage: '$revenueTrendPercent%',
                            icon: Icons.attach_money,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        TrendCard(
                          title: 'Nuevos Socios',
                          currentValue: '$currentMonthMembers',
                          previousValue: '$previousMonthMembers',
                          trend: membersTrend,
                          trendPercentage: '$membersTrendPercent%',
                          icon: Icons.person_add,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        TrendCard(
                          title: 'Ingresos',
                          currentValue: MoneyFormatter.format(currentMonthRevenue),
                          previousValue: MoneyFormatter.format(previousMonthRevenue),
                          trend: revenueTrend,
                          trendPercentage: '$revenueTrendPercent%',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 32),

              // Gráfico de Nuevos Socios por Mes
              if (_newMembersStats.isNotEmpty)
                StatsCard(
                  title: 'Nuevos Socios por Mes',
                  subtitle: 'Últimos 6 meses',
                  child: SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _newMembersStats.isEmpty
                            ? 50
                            : (_newMembersStats
                                    .map((m) => (m['count'] ?? 0) as num)
                                    .reduce((a, b) => a > b ? a : b)
                                    .toDouble() *
                                1.2),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
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
                                final index = value.toInt();
                                if (index >= 0 &&
                                    index < _newMembersStats.length) {
                                  final month =
                                      _newMembersStats[index]['month'] ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      month.length >= 3
                                          ? month.substring(0, 3)
                                          : month,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 10,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.3),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          _newMembersStats.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: (_newMembersStats[index]['count'] ?? 0)
                                    .toDouble(),
                                color: colorScheme.primary,
                                width: 24,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    colorScheme.primary.withValues(alpha: 0.7),
                                    colorScheme.primary,
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Gráfico de Ingresos por Mes
              if (monthlyRevenue.isNotEmpty)
                StatsCard(
                  title: 'Ingresos Mensuales',
                  subtitle: 'Tendencia de los últimos meses',
                  child: SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 10000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.3),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '\$${(value / 1000).toStringAsFixed(0)}k',
                                  style: theme.textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < monthlyRevenue.length) {
                                  final month =
                                      monthlyRevenue[index]['month'] ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      month.length >= 3
                                          ? month.substring(0, 3)
                                          : month,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              monthlyRevenue.length,
                              (index) => FlSpot(
                                index.toDouble(),
                                (monthlyRevenue[index]['amount'] ?? 0)
                                    .toDouble(),
                              ),
                            ),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: Colors.green,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: Colors.green,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.green.withValues(alpha: 0.3),
                                  Colors.green.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Distribución de Planes
              if (planDistribution.isNotEmpty)
                StatsCard(
                  title: 'Planes Más Populares',
                  subtitle: 'Distribución por tipo de plan',
                  child: SizedBox(
                    height: 240,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PieChart(
                            PieChartData(
                              sections: planDistribution.map((plan) {
                                final colors = [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                  colorScheme.tertiary,
                                  Colors.orange,
                                  Colors.purple,
                                ];
                                final index = planDistribution.indexOf(plan);
                                final color = colors[index % colors.length];

                                return PieChartSectionData(
                                  value: (plan['count'] ?? 0).toDouble(),
                                  title:
                                      '${plan['percentage']?.toStringAsFixed(0) ?? 0}%',
                                  color: color,
                                  radius: 70,
                                  titleStyle:
                                      theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList(),
                              centerSpaceRadius: 50,
                              sectionsSpace: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: planDistribution.map((plan) {
                              final colors = [
                                colorScheme.primary,
                                colorScheme.secondary,
                                colorScheme.tertiary,
                                Colors.orange,
                                Colors.purple,
                              ];
                              final index = planDistribution.indexOf(plan);
                              final color = colors[index % colors.length];

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        plan['planName'] ?? 'N/A',
                                        style: theme.textTheme.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${plan['count']}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Pagos Recientes
              StatsCard(
                title: 'Pagos Recientes',
                subtitle: 'Últimas transacciones',
                padding: EdgeInsets.zero,
                child: recentPayments.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: Text('No hay pagos recientes'),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentPayments.take(5).length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                        ),
                        itemBuilder: (context, index) {
                          final payment = recentPayments[index];
                          final memberName =
                              payment['memberName'] ?? 'Sin nombre';
                          final amountValue = payment['amount'] ?? 0;
                          final amount = amountValue is int 
                              ? amountValue.toDouble() 
                              : (amountValue is double ? amountValue : 0.0);
                          final method = payment['method'] ?? 'N/A';
                          final status = payment['status'] ?? 'N/A';
                          final date = payment['paymentDate'];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.payment,
                                color: Colors.green,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              memberName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '$method${date != null ? ' • ${DateFormatter.formatDate(DateTime.parse(date))}' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 200) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          MoneyFormatter.format(amount),
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: status == 'Completado'
                                              ? Colors.green.withValues(alpha: 0.15)
                                              : Colors.orange.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          status,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: status == 'Completado'
                                                ? Colors.green
                                                : Colors.orange,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          MoneyFormatter.format(amount),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget helper para headers de sección
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
