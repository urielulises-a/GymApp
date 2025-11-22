import 'package:flutter/material.dart';
import '../../core/models/attendance.dart';
import '../../core/models/member.dart';
import '../../core/services/attendance_service.dart';
import '../../core/services/members_service.dart';
import '../../core/services/http_service.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/export_utils.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final _attendanceService = AttendanceService();
  final _membersService = MembersService();
  final _qrController = TextEditingController();
  final _searchController = TextEditingController();

  List<Attendance> _attendances = [];
  List<Member> _members = [];
  List<Member> _filteredMembersForSearch = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _statusFilter;
  String? _memberFilter;
  DateTimeRange? _dateRange;
  bool _showMemberSuggestions = false;

  String? _selectedMemberId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _qrController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterMembers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMembersForSearch = [];
        _showMemberSuggestions = false;
      } else {
        _filteredMembersForSearch = _members.where((member) {
          return member.name.toLowerCase().contains(query.toLowerCase()) ||
              member.email.toLowerCase().contains(query.toLowerCase()) ||
              member.phone?.toLowerCase().contains(query.toLowerCase()) == true ||
              member.displayId.toLowerCase().contains(query.toLowerCase());
        }).take(5).toList();
        _showMemberSuggestions = _filteredMembersForSearch.isNotEmpty;
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final attendanceResponse = await _attendanceService.getAttendance(
        page: 1,
        limit: 100,
        memberId: _memberFilter,
        status: _statusFilter,
        fromDate: _dateRange?.start.toIso8601String(),
        toDate: _dateRange?.end.toIso8601String(),
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

  Future<void> _checkIn({String? memberId}) async {
    final memberIdToUse = memberId ?? _selectedMemberId;
    if (memberIdToUse == null) {
      _showError('Por favor selecciona un socio');
      return;
    }

    try {
      await _attendanceService.checkIn(memberIdToUse);

      final member = _members.firstWhere(
        (m) => m.id == memberIdToUse,
        orElse: () => Member(
          id: memberIdToUse,
          name: 'Desconocido',
          email: '',
          phone: '',
          joinDate: DateTime.now().toIso8601String(),
          status: '',
          planId: '',
          displayId: '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );

      _showSuccess('Check-in registrado para ${member.name}');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al registrar entrada: ${e.message}');
    }
  }

  Future<void> _checkOut(Attendance attendance) async {
    try {
      await _attendanceService.checkOut(attendance.id);
      _showSuccess('Check-out registrado');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al registrar salida: ${e.message}');
    }
  }

  Future<void> _deleteAttendance(Attendance attendance) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('Eliminar el registro ${attendance.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _attendanceService.deleteAttendance(attendance.id);
      _showSuccess('Registro eliminado');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al eliminar: ${e.message}');
    }
  }

  List<Attendance> get _filteredAttendance {
    return _attendances.where((attendance) {
      final matchesSearch = _searchQuery.isEmpty ||
          attendance.id.toLowerCase().contains(_searchQuery);
      return matchesSearch;
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
                value: tempStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todos')),
                  DropdownMenuItem(value: 'Completado', child: Text('Completado')),
                  DropdownMenuItem(value: 'En curso', child: Text('En curso')),
                ],
                onChanged: (value) => setModalState(() => tempStatus = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: tempMember,
                decoration: const InputDecoration(
                  labelText: 'Socio',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ..._members.map((member) => DropdownMenuItem(
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
                      : '${DateFormatter.formatDate(tempRange!.start)} - ${DateFormatter.formatDate(tempRange!.end)}',
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
                      _loadData();
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
      final member = _members.firstWhere(
        (m) => m.id == record.memberId,
        orElse: () => Member(
          id: record.memberId,
          name: 'Desconocido',
          email: '',
          phone: '',
          joinDate: DateTime.now().toIso8601String(),
          status: '',
          planId: '',
          displayId: '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      return [
        record.id,
        member.name,
        DateFormatter.formatDateTime(record.checkInTime),
        record.checkOutTime != null
            ? DateFormatter.formatDateTime(record.checkOutTime!)
            : '-',
        record.status,
      ].map((e) => e ?? '').toList();
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
                    const Text('Apunta el codigo QR al marco'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qrController,
              decoration: const InputDecoration(
                labelText: 'Codigo manual (ID de socio)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                final code = _qrController.text.trim();
                if (code.isEmpty || !_members.any((m) => m.id == code)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Codigo invalido')),
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

    final columns = ['ID', 'Socio', 'Entrada', 'Salida', 'Estado'];
    final attendanceRecords = _filteredAttendance;
    final rows = attendanceRecords.map((attendance) {
      final member = _members.firstWhere(
        (m) => m.id == attendance.memberId,
        orElse: () => Member(
          id: attendance.memberId,
          name: 'Desconocido',
          email: '',
          phone: '',
          joinDate: DateTime.now().toIso8601String(),
          status: '',
          planId: '',
          displayId: '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      return [
        attendance.id,
        member.name,
        DateFormatter.formatTime(attendance.checkInTime),
        attendance.checkOutTime != null
            ? DateFormatter.formatTime(attendance.checkOutTime!)
            : 'En curso',
        attendance.status,
      ].map((e) => e ?? '').toList();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  value: _selectedMemberId,
                                  decoration: const InputDecoration(
                                    labelText: 'Seleccionar Socio',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _members
                                      .map((member) => DropdownMenuItem(
                                            value: member.id,
                                            child: Text(member.name),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMemberId = value;
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
