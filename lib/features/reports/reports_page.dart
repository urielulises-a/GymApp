import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/services/reports_service.dart';
import '../../core/services/dashboard_service.dart';
import '../../core/services/http_service.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/widgets/stats_card.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  final _reportsService = ReportsService();
  final _dashboardService = DashboardService();

  late TabController _tabController;

  Map<String, dynamic> _summary = {};
  Map<String, dynamic> _peakHours = {};
  Map<String, dynamic> _membersStatusDistribution = {};
  Map<String, dynamic> _renewalsStats = {};
  Map<String, dynamic> _revenueTrends = {};
  Map<String, dynamic> _avgSessionDuration = {};
  List<Map<String, dynamic>> _paymentsByCategory = [];
  List<Map<String, dynamic>> _topAttendanceDays = [];
  List<Map<String, dynamic>> _newMembersStats = [];

  bool _isLoading = false;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      // Cargar datos en paralelo para mejor rendimiento
      final results = await Future.wait([
        _reportsService.getSummary(),
        _dashboardService.getPeakHours(
          fromDate: _fromDate?.toIso8601String(),
          toDate: _toDate?.toIso8601String(),
        ),
        _dashboardService.getMembersStatusDistribution(),
        _dashboardService.getRenewalsStats(),
        _dashboardService.getRevenueTrends(months: 6),
        _dashboardService.getAverageSessionDuration(),
        _dashboardService.getPaymentsByCategory(),
        _dashboardService.getTopAttendanceDays(limit: 7),
        _dashboardService.getNewMembersStats(months: 6),
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as Map<String, dynamic>;
          _peakHours = results[1] as Map<String, dynamic>;
          _membersStatusDistribution = results[2] as Map<String, dynamic>;
          _renewalsStats = results[3] as Map<String, dynamic>;
          _revenueTrends = results[4] as Map<String, dynamic>;
          _avgSessionDuration = results[5] as Map<String, dynamic>;
          _paymentsByCategory = results[6] as List<Map<String, dynamic>>;
          _topAttendanceDays = results[7] as List<Map<String, dynamic>>;
          _newMembersStats = results[8] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error al cargar reportes: ${e.message}');
      }
    }
  }

  Future<void> _exportCsv() async {
    try {
      await _reportsService.exportCsv(
        fromDate: _fromDate?.toIso8601String(),
        toDate: _toDate?.toIso8601String(),
      );
      _showSuccess('Reporte CSV exportado exitosamente');
    } on ApiException catch (e) {
      _showError('Error al exportar CSV: ${e.message}');
    }
  }

  Future<void> _exportPdf() async {
    try {
      await _reportsService.exportPdf(
        fromDate: _fromDate?.toIso8601String(),
        toDate: _toDate?.toIso8601String(),
      );
      _showSuccess('Reporte PDF generado exitosamente');
    } on ApiException catch (e) {
      _showError('Error al exportar PDF: ${e.message}');
    }
  }

  Future<void> _printReports() async {
    final revenue = _summary['revenue'] as Map<String, dynamic>? ?? {};
    final members = _summary['members'] as Map<String, dynamic>? ?? {};

    final totalRevenue = revenue['total'] ?? 0;
    final totalMembers = members['total'] ?? 0;
    final activeMembers = members['active'] ?? 0;
    final growth = members['growth'] ?? 0;

    final summaryData = {
      'Ingresos Totales': MoneyFormatter.format(totalRevenue),
      'Total de Socios': '$totalMembers',
      'Socios Activos': '$activeMembers',
      'Nuevos este mes': '$growth',
    };

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
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                ...summaryData.entries.map(
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

  void _showDateRangeFilter() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );

    if (range != null) {
      setState(() {
        _fromDate = range.start;
        _toDate = range.end;
      });
      _loadReports();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const AppScaffold(
        title: 'Reportes y Estadísticas',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: 'Reportes y Estadísticas',
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filtrar por fechas',
          onPressed: _showDateRangeFilter,
        ),
        IconButton(
          icon: const Icon(Icons.download),
          tooltip: 'Exportar CSV',
          onPressed: _exportCsv,
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Exportar PDF',
          onPressed: _exportPdf,
        ),
        IconButton(
          icon: const Icon(Icons.print),
          tooltip: 'Imprimir',
          onPressed: _printReports,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _loadReports,
        tooltip: 'Actualizar',
        child: const Icon(Icons.refresh),
      ),
      body: Column(
        children: [
          if (_fromDate != null && _toDate != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Filtrado: ${DateFormatter.formatDate(_fromDate!)} - ${DateFormatter.formatDate(_toDate!)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _fromDate = null;
                        _toDate = null;
                      });
                      _loadReports();
                    },
                  ),
                ],
              ),
            ),
          Container(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'General', icon: Icon(Icons.dashboard, size: 20)),
                Tab(text: 'Ingresos', icon: Icon(Icons.attach_money, size: 20)),
                Tab(
                    text: 'Asistencias',
                    icon: Icon(Icons.people_alt, size: 20)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(theme, colorScheme),
                _buildRevenueTab(theme, colorScheme),
                _buildAttendanceTab(theme, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(ThemeData theme, ColorScheme colorScheme) {
    final revenue = _summary['revenue'] as Map<String, dynamic>? ?? {};
    final members = _summary['members'] as Map<String, dynamic>? ?? {};
    final planDistribution = _summary['planDistribution'] as List<dynamic>? ?? [];

    final totalRevenue = revenue['total'] ?? 0;
    final totalMembers = members['total'] ?? 0;
    final activeMembers = members['active'] ?? 0;
    final growth = members['growth'] ?? 0;

    final activeCount = _membersStatusDistribution['active'] ?? 0;
    final inactiveCount = _membersStatusDistribution['inactive'] ?? 0;
    final totalCount = activeCount + inactiveCount;
    final activePercentage =
        totalCount > 0 ? (activeCount / totalCount * 100).toStringAsFixed(1) : '0';
    final inactivePercentage = totalCount > 0
        ? (inactiveCount / totalCount * 100).toStringAsFixed(1)
        : '0';

    final renewalRate = _renewalsStats['rate'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPIs Principales
            SectionHeader(
              title: 'Métricas Clave',
              subtitle: 'Resumen general del negocio',
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                KpiCard(
                  title: 'Ingresos Totales',
                  value: MoneyFormatter.format(totalRevenue),
                  subtitle: 'Últimos 6 meses',
                  icon: Icons.attach_money_outlined,
                  color: Colors.green,
                ),
                KpiCard(
                  title: 'Total Socios',
                  value: '$totalMembers',
                  subtitle: growth > 0 ? '+$growth nuevos' : 'Miembros totales',
                  icon: Icons.group,
                  color: colorScheme.primary,
                  trend: growth > 0 ? 'up' : (growth < 0 ? 'down' : 'neutral'),
                  trendValue: growth > 0 ? '+$growth' : '$growth',
                ),
                KpiCard(
                  title: 'Socios Activos',
                  value: '$activeMembers',
                  subtitle: 'Con suscripción vigente',
                  icon: Icons.person_outlined,
                  color: Colors.purple,
                ),
                KpiCard(
                  title: 'Tasa de Retención',
                  value: '${renewalRate.toStringAsFixed(1)}%',
                  subtitle: 'Renovaciones mensuales',
                  icon: Icons.refresh_outlined,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Distribución Activos vs Inactivos
            StatsCard(
              title: 'Distribución de Socios',
              subtitle: 'Activos vs Inactivos',
              child: SizedBox(
                height: 240,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: activeCount.toDouble(),
                              title: '$activePercentage%',
                              color: Colors.green,
                              radius: 70,
                              titleStyle: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: inactiveCount.toDouble(),
                              title: '$inactivePercentage%',
                              color: Colors.red.withValues(alpha: 0.7),
                              radius: 70,
                              titleStyle: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                        children: [
                          InfoListItem(
                            label: 'Socios Activos',
                            value: '$activeCount',
                            icon: Icons.check_circle,
                            iconColor: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          InfoListItem(
                            label: 'Socios Inactivos',
                            value: '$inactiveCount',
                            icon: Icons.cancel,
                            iconColor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nuevos Socios por Mes
            if (_newMembersStats.isNotEmpty)
              StatsCard(
                title: 'Crecimiento de Socios',
                subtitle: 'Nuevos socios por mes',
                child: SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
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
                              if (index >= 0 && index < _newMembersStats.length) {
                                final month = _newMembersStats[index]['month'] ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    month.length >= 3 ? month.substring(0, 3) : month,
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
                            _newMembersStats.length,
                            (index) => FlSpot(
                              index.toDouble(),
                              (_newMembersStats[index]['count'] ?? 0).toDouble(),
                            ),
                          ),
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: colorScheme.primary,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: colorScheme.primary,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                colorScheme.primary.withValues(alpha: 0.3),
                                colorScheme.primary.withValues(alpha: 0.05),
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
                title: 'Planes Más Vendidos',
                subtitle: 'Distribución por tipo de plan',
                child: Column(
                  children: planDistribution.map((plan) {
                    final colors = [
                      colorScheme.primary,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.blue,
                    ];
                    final index = planDistribution.indexOf(plan);
                    final color = colors[index % colors.length];
                    final percentage = plan['percentage']?.toDouble() ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                plan['planName'] ?? 'N/A',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${plan['count']} (${percentage.toStringAsFixed(1)}%)',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 12,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
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
    );
  }

  Widget _buildRevenueTab(ThemeData theme, ColorScheme colorScheme) {
    final revenue = _summary['revenue'] as Map<String, dynamic>? ?? {};
    final monthlyRevenue = revenue['monthly'] as List<dynamic>? ?? [];
    final totalRevenue = revenue['total'] ?? 0;

    final currentMonthRevenue = _revenueTrends['currentMonth'] ?? 0;
    final previousMonthRevenue = _revenueTrends['previousMonth'] ?? 0;
    final revenueDiff = currentMonthRevenue - previousMonthRevenue;
    final revenueTrend =
        revenueDiff > 0 ? 'up' : (revenueDiff < 0 ? 'down' : 'neutral');
    final revenueTrendPercent = previousMonthRevenue > 0
        ? ((revenueDiff / previousMonthRevenue) * 100).abs().toStringAsFixed(1)
        : '0.0';

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Análisis de Ingresos',
              subtitle: 'Métricas financieras detalladas',
            ),
            const SizedBox(height: 16),

            // Comparativa de ingresos
            Row(
              children: [
                Expanded(
                  child: TrendCard(
                    title: 'Mes Actual',
                    currentValue: MoneyFormatter.format(currentMonthRevenue),
                    previousValue: MoneyFormatter.format(previousMonthRevenue),
                    trend: revenueTrend,
                    trendPercentage: '$revenueTrendPercent%',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    title: 'Total Histórico',
                    value: MoneyFormatter.format(totalRevenue),
                    subtitle: 'Últimos 6 meses',
                    icon: Icons.account_balance_wallet,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Gráfico de barras de ingresos mensuales
            if (monthlyRevenue.isNotEmpty)
              StatsCard(
                title: 'Ingresos por Mes',
                subtitle: 'Evolución mensual',
                child: SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: monthlyRevenue.isEmpty
                          ? 150000
                          : (monthlyRevenue
                                  .map((m) => (m['amount'] ?? 0) as num)
                                  .reduce((a, b) => a > b ? a : b)
                                  .toDouble() *
                              1.2),
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
                                final month = monthlyRevenue[index]['month'] ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    month.length >= 3 ? month.substring(0, 3) : month,
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
                        horizontalInterval: 20000,
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
                        monthlyRevenue.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: (monthlyRevenue[index]['amount'] ?? 0)
                                  .toDouble(),
                              color: Colors.green,
                              width: 28,
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(6)),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.green.withValues(alpha: 0.7),
                                  Colors.green,
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

            // Pagos por Categoría/Método
            if (_paymentsByCategory.isNotEmpty)
              StatsCard(
                title: 'Ingresos por Método de Pago',
                subtitle: 'Distribución de pagos',
                child: Column(
                  children: _paymentsByCategory.map((category) {
                    final colors = [
                      Colors.green,
                      Colors.blue,
                      Colors.orange,
                      Colors.purple,
                    ];
                    final index = _paymentsByCategory.indexOf(category);
                    final color = colors[index % colors.length];
                    final method = category['method'] ?? 'N/A';
                    final amount = category['total'] ?? 0;
                    final count = category['count'] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getPaymentIcon(method),
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$count transacciones',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            MoneyFormatter.format(amount),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
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
    );
  }

  Widget _buildAttendanceTab(ThemeData theme, ColorScheme colorScheme) {
    final avgDuration = _avgSessionDuration['average'] ?? 0;
    final totalSessions = _avgSessionDuration['totalSessions'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Análisis de Asistencias',
              subtitle: 'Patrones y tendencias de uso',
            ),
            const SizedBox(height: 16),

            // KPIs de asistencia
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Duración Promedio',
                    value: '${avgDuration.toStringAsFixed(0)} min',
                    subtitle: 'Por sesión',
                    icon: Icons.timer,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    title: 'Total Sesiones',
                    value: '$totalSessions',
                    subtitle: 'Registradas',
                    icon: Icons.fitness_center,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Días de mayor afluencia
            if (_topAttendanceDays.isNotEmpty)
              StatsCard(
                title: 'Días de Mayor Afluencia',
                subtitle: 'Top 7 días con más asistencias',
                child: Column(
                  children: _topAttendanceDays.map((day) {
                    final index = _topAttendanceDays.indexOf(day);
                    final date = day['date'] ?? '';
                    final count = day['count'] ?? 0;
                    final maxCount = _topAttendanceDays.isEmpty
                        ? 1
                        : (_topAttendanceDays
                                .map((d) => d['count'] as num? ?? 0)
                                .reduce((a, b) => a > b ? a : b))
                            .toDouble();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormatter.formatDate(DateTime.parse(date)),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: count / maxCount,
                                    minHeight: 8,
                                    backgroundColor:
                                        colorScheme.surfaceContainerHighest,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '$count',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 20),

            // Horas Pico
            if (_peakHours.isNotEmpty)
              StatsCard(
                title: 'Horas Pico por Día',
                subtitle: 'Horarios de mayor actividad',
                child: Column(
                  children: (_peakHours['days'] as List<dynamic>? ?? [])
                      .map((dayData) {
                    final day = dayData['day'] ?? 'N/A';
                    final peakHour = dayData['peakHour'] ?? 'N/A';
                    final count = dayData['count'] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              day,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                peakHour,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$count',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
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
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'efectivo':
        return Icons.money;
      case 'tarjeta':
      case 'tarjeta de crédito':
      case 'tarjeta de débito':
        return Icons.credit_card;
      case 'transferencia':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}

// Widget helper
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

class InfoListItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const InfoListItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? colorScheme.primary).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
