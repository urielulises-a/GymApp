import 'package:flutter/material.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/dates.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String _selectedMember = 'M001';

  void _checkIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demostración: Check-in registrado exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Preparar datos para la tabla
    final columns = ['ID', 'Socio', 'Entrada', 'Salida', 'Estado'];
    final rows = kAttendance.map((attendance) {
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad de escáner QR en desarrollo')),
            );
          },
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
                            value: _selectedMember,
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar Socio',
                              border: OutlineInputBorder(),
                            ),
                            items: kMembers.map((member) => DropdownMenuItem(
                              value: member.id,
                              child: Text(member.name),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMember = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: _checkIn,
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
                            '${kAttendance.length}',
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
                            '${kAttendance.where((a) => a.status == 'En curso').length}',
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidad de filtros en desarrollo')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidad de exportación en desarrollo')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
