import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models/attendance.dart';
import '../../core/models/member.dart';
import '../../core/services/attendance_service.dart';
import '../../core/services/members_service.dart';
import '../../core/services/http_service.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/app_scaffold.dart';

class AttendancePageNew extends StatefulWidget {
  const AttendancePageNew({super.key});

  @override
  State<AttendancePageNew> createState() => _AttendancePageNewState();
}

class _AttendancePageNewState extends State<AttendancePageNew>
    with SingleTickerProviderStateMixin {
  final _attendanceService = AttendanceService();
  final _membersService = MembersService();
  final _searchController = TextEditingController();

  late TabController _tabController;

  List<Attendance> _attendances = [];
  List<Member> _members = [];
  List<Member> _filteredMembers = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Cargar asistencias del día actual
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final attendanceResponse = await _attendanceService.getAttendance(
        page: 1,
        limit: 500,
        fromDate: startOfDay.toIso8601String(),
        toDate: endOfDay.toIso8601String(),
      );

      final membersResponse = await _membersService.getMembers(
        page: 1,
        limit: 1000,
        status: 'Activo',
      );

      if (mounted) {
        setState(() {
          _attendances = attendanceResponse.data ?? [];
          _members = membersResponse.data ?? [];
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error al cargar datos: ${e.message}');
      }
    }
  }

  void _filterMembers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMembers = [];
        _showSuggestions = false;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredMembers = _members.where((member) {
        return member.name.toLowerCase().contains(lowercaseQuery) ||
            member.email.toLowerCase().contains(lowercaseQuery) ||
            member.phone?.toLowerCase().contains(lowercaseQuery) == true ||
            member.displayId.toLowerCase().contains(lowercaseQuery);
      }).take(5).toList();
      _showSuggestions = _filteredMembers.isNotEmpty;
    });
  }

  Future<void> _checkIn(Member member) async {
    try {
      // Verificar si ya tiene un check-in activo
      final activeAttendance = _attendances.firstWhere(
        (a) => a.memberId == member.id && a.status == 'En curso',
        orElse: () => Attendance(
          id: '',
          displayId: '',
          memberId: '',
          memberName: '',
          checkInTime: '',
          status: '',
          createdAt: '',
          updatedAt: '',
        ),
      );

      if (activeAttendance.id.isNotEmpty) {
        _showError('${member.name} ya tiene un check-in activo');
        return;
      }

      await _attendanceService.checkIn(member.id);
      _showSuccess('Check-in registrado para ${member.name}');
      _searchController.clear();
      setState(() {
        _showSuggestions = false;
        _filteredMembers = [];
      });
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al registrar entrada: ${e.message}');
    }
  }

  Future<void> _checkOut(Attendance attendance) async {
    try {
      await _attendanceService.checkOut(attendance.id);
      _showSuccess('Check-out registrado para ${attendance.memberName}');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al registrar salida: ${e.message}');
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

  Map<int, int> _getHourlyAttendance() {
    final hourlyData = <int, int>{};

    // Inicializar todas las horas del día
    for (int i = 0; i < 24; i++) {
      hourlyData[i] = 0;
    }

    // Contar asistencias por hora
    for (final attendance in _attendances) {
      try {
        final checkInTime = DateTime.parse(attendance.checkInTime);
        final hour = checkInTime.hour;
        hourlyData[hour] = (hourlyData[hour] ?? 0) + 1;
      } catch (e) {
        // Ignorar errores de parsing
      }
    }

    return hourlyData;
  }

  Widget _buildCheckInTab() {
    final activeAttendances =
        _attendances.where((a) => a.status == 'En curso').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de búsqueda rápida
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registro de entrada',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar socio',
                      hintText: 'Nombre, email, teléfono o ID...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onChanged: _filterMembers,
                  ),
                  if (_showSuggestions) ...[
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      child: Column(
                        children: _filteredMembers.map((member) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Text(
                                member.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(member.name),
                            subtitle: Text(
                                '${member.email} • ID: ${member.displayId}'),
                            trailing: ElevatedButton.icon(
                              onPressed: () => _checkIn(member),
                              icon: const Icon(Icons.login, size: 18),
                              label: const Text('Check-in'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Estadísticas del día
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(Icons.people, size: 40, color: Colors.blue.shade700),
                        const SizedBox(height: 12),
                        Text(
                          '${_attendances.length}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const Text(
                          'Registros hoy',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(Icons.person, size: 40, color: Colors.purple.shade700),
                        const SizedBox(height: 12),
                        Text(
                          '${activeAttendances.length}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const Text(
                          'En gimnasio',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Lista de personas actualmente en el gimnasio
          Text(
            'Actualmente en el gimnasio',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (activeAttendances.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.person_off, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay socios en el gimnasio',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...activeAttendances.map((attendance) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: Text(
                      attendance.memberName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    attendance.memberName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Entrada: ${DateFormatter.formatTime(attendance.checkInTime)}',
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () => _checkOut(attendance),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Check-out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final hourlyData = _getHourlyAttendance();
    final peakHour = hourlyData.entries.reduce((a, b) => a.value > b.value ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de afluencia',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // Información de hora pico
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.trending_up, size: 48, color: Colors.amber.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hora pico del día',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${peakHour.key}:00 - ${peakHour.key + 1}:00',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        Text(
                          '${peakHour.value} visitas',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Gráfico de barras por hora
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asistencias por hora',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (hourlyData.values.reduce((a, b) => a > b ? a : b) + 5).toDouble(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${group.x}:00\n${rod.toY.round()} visitas',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() % 2 == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${value.toInt()}h',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: hourlyData.entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.toDouble(),
                                color: entry.key == peakHour.key
                                    ? Colors.amber.shade700
                                    : Colors.blue.shade400,
                                width: 16,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Tabla de horarios
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tabla de horarios',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade100),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Hora',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Visitas',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Nivel',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      ...hourlyData.entries.where((e) => e.value > 0).map((entry) {
                        String level;
                        Color levelColor;
                        if (entry.value >= peakHour.value * 0.7) {
                          level = 'Alto';
                          levelColor = Colors.red;
                        } else if (entry.value >= peakHour.value * 0.4) {
                          level = 'Medio';
                          levelColor = Colors.orange;
                        } else {
                          level = 'Bajo';
                          levelColor = Colors.green;
                        }

                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text('${entry.key}:00 - ${entry.key + 1}:00'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text('${entry.value}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: levelColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: levelColor),
                                ),
                                child: Text(
                                  level,
                                  style: TextStyle(
                                    color: levelColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Asistencia',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Check-in / Check-out', icon: Icon(Icons.login)),
                    Tab(text: 'Análisis de horarios', icon: Icon(Icons.analytics)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCheckInTab(),
                      _buildAnalyticsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
