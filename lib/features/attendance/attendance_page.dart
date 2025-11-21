import 'package:flutter/material.dart';

import '../../core/utils/dates.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/export_utils.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late final List<Attendance> _attendances;
  String _selectedMember = 'M001';
  String _searchQuery = '';
  String? _statusFilter;
  String? _memberFilter;
  DateTimeRange? _dateRange;
  final _qrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _attendances = List<Attendance>.from(kAttendance);
  }

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  void _checkIn({String? memberId}) {
    final member =
        kMembers.firstWhere((m) => m.id == (memberId ?? _selectedMember));
    final entry = Attendance(
      id: _generateAttendanceId(),
      memberId: member.id,
      checkInTime: DateTime.now(),
      checkOutTime: null,
      status: 'En curso',
    );

    setState(() {
      _attendances.insert(0, entry);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Check-in registrado para ${member.name}')),
    );
  }

  List<Attendance> get _filteredAttendance {
    return _attendances.where((attendance) {
      final member = kMembers.firstWhere((m) => m.id == attendance.memberId);
      final matchesSearch = _searchQuery.isEmpty ||
          member.name.toLowerCase().contains(_searchQuery) ||
          attendance.id.toLowerCase().contains(_searchQuery);
      final matchesStatus =
          _statusFilter == null || attendance.status == _statusFilter;
      final matchesMember =
          _memberFilter == null || attendance.memberId == _memberFilter;
      final matchesDate = _dateRange == null ||
          (attendance.checkInTime.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1))) &&
              attendance.checkInTime
                  .isBefore(_dateRange!.end.add(const Duration(days: 1))));
      return matchesSearch && matchesStatus && matchesMember && matchesDate;
    }).toList();
  }

  void _openFilterSheet() {
    String? tempStatus = _statusFilter;
    String? tempMember = _memberFilter;
    DateTimeRange? tempRange = _dateRange;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: StatefulBuilder(
          builder: (context, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                // ignore: deprecated_member_use
                value: tempStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todos')),
                  DropdownMenuItem(
                      value: 'Completado', child: Text('Completado')),
                  DropdownMenuItem(value: 'En curso', child: Text('En curso')),
                ],
                onChanged: (value) => setModalState(() => tempStatus = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                // ignore: deprecated_member_use
                value: tempMember,
                decoration: const InputDecoration(
                  labelText: 'Socio',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ...kMembers.map((member) => DropdownMenuItem(
                        value: member.id,
                        child: Text(member.name),
                      )),
                ],
                onChanged: (value) => setModalState(() => tempMember = value),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range),
                title: const Text('Rango de fechas'),
                subtitle: Text(
                  tempRange == null
                      ? 'Sin filtro'
                      : '${DateFormatter.formatDate(tempRange!.start)} — ${DateFormatter.formatDate(tempRange!.end)}',
                ),
                onTap: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                    initialDateRange: tempRange,
                  );
                  if (range != null) {
                    setModalState(() => tempRange = range);
                  }
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        tempStatus = null;
                        tempMember = null;
                        tempRange = null;
                      });
                    },
                    child: const Text('Limpiar'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _statusFilter = tempStatus;
                        _memberFilter = tempMember;
                        _dateRange = tempRange;
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportAttendance(List<Attendance> attendance) {
    final rows = attendance.map((record) {
      final member = kMembers.firstWhere((m) => m.id == record.memberId);
      return [
        record.id,
        member.name,
        DateFormatter.formatDateTime(record.checkInTime),
        record.checkOutTime != null
            ? DateFormatter.formatDateTime(record.checkOutTime!)
            : '—',
        record.status,
      ];
    }).toList();

    DataExporter.copyAsCsv(
      context: context,
      fileName: 'asistencia',
      headers: ['ID', 'Socio', 'Entrada', 'Salida', 'Estado'],
      rows: rows,
    );
  }

  void _openQrScanner() {
    _qrController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner,
                        size: 72, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    const Text('Apunta el código QR al marco'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qrController,
              decoration: const InputDecoration(
                labelText: 'Código manual (ID de socio)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                final code = _qrController.text.trim();
                if (code.isEmpty || !kMembers.any((m) => m.id == code)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código inválido')),
                  );
                  return;
                }
                Navigator.of(context).pop();
                _checkIn(memberId: code);
              },
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Registrar desde QR'),
            ),
          ],
        ),
      ),
    );
  }

  String _generateAttendanceId() {
    final next = _attendances.length + 1;
    return 'A${next.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Preparar datos para la tabla
    final columns = ['ID', 'Socio', 'Entrada', 'Salida', 'Estado'];
    final attendanceRecords = _filteredAttendance;
    final rows = attendanceRecords.map((attendance) {
      final member = kMembers.firstWhere((m) => m.id == attendance.memberId);
      return [
        attendance.id,
        member.name,
        DateFormatter.formatTime(attendance.checkInTime),
        attendance.checkOutTime != null
            ? DateFormatter.formatTime(attendance.checkOutTime!)
            : 'En curso',
        attendance.status,
      ];
    }).toList();

    return AppScaffold(
      title: 'Asistencia',
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'Escanear QR',
          onPressed: _openQrScanner,
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check-in Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registro de Asistencia',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedMember,
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar Socio',
                              border: OutlineInputBorder(),
                            ),
                            items: kMembers
                                .map((member) => DropdownMenuItem(
                                      value: member.id,
                                      child: Text(member.name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMember = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: () => _checkIn(),
                          icon: const Icon(Icons.login),
                          label: const Text('Check-in'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_attendances.length}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Registros Hoy',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 32,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_attendances.where((a) => a.status == 'En curso').length}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                          Text(
                            'En Gimnasio',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Attendance Table
            DataTableX(
              columns: columns,
              rows: rows,
              searchHint: 'Buscar asistencia...',
              onSearchChanged: (value) => setState(() {
                _searchQuery = value.toLowerCase();
              }),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filtros',
                  onPressed: _openFilterSheet,
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Exportar CSV',
                  onPressed: () => _exportAttendance(attendanceRecords),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
