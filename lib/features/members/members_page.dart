import 'package:flutter/material.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/export_utils.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';
import '../../core/widgets/form_dialog.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  late final List<Member> _members;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedPlan = 'P001';
  String _selectedStatus = 'Activo';
  String _searchQuery = '';
  String? _statusFilter;
  String? _planFilter;
  DateTimeRange? _joinDateRange;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _members = List<Member>.from(kMembers);
  }

  void _showAddMemberDialog() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _selectedPlan = 'P001';
    _selectedStatus = 'Activo';

    showDialog(
      context: context,
      builder: (context) => FormDialog(
        title: 'Agregar Nuevo Socio',
        fields: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el correo';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Por favor ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el teléfono';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _selectedPlan,
            decoration: const InputDecoration(
              labelText: 'Plan',
              border: OutlineInputBorder(),
            ),
            items: kPlans
                .map((plan) => DropdownMenuItem(
                      value: plan.id,
                      child: Text('${plan.name} - ${plan.price}'),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedPlan = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Estado',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Activo', child: Text('Activo')),
              DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
              DropdownMenuItem(value: 'Suspendido', child: Text('Suspendido')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
        ],
        onSave: () {
          final member = Member(
            id: _generateMemberId(),
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            joinDate: DateTime.now(),
            status: _selectedStatus,
            planId: _selectedPlan,
          );

          setState(() {
            _members.add(member);
          });

          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Socio ${member.name} agregado')),
            );
          }
        },
      ),
    );
  }

  List<Member> get _filteredMembers {
    return _members.where((member) {
      final matchesSearch = _searchQuery.isEmpty ||
          member.name.toLowerCase().contains(_searchQuery) ||
          member.email.toLowerCase().contains(_searchQuery) ||
          member.phone.toLowerCase().contains(_searchQuery);
      final matchesStatus =
          _statusFilter == null || member.status == _statusFilter;
      final matchesPlan = _planFilter == null || member.planId == _planFilter;
      final matchesDate = _joinDateRange == null ||
          (member.joinDate.isAfter(
                  _joinDateRange!.start.subtract(const Duration(days: 1))) &&
              member.joinDate
                  .isBefore(_joinDateRange!.end.add(const Duration(days: 1))));
      return matchesSearch && matchesStatus && matchesPlan && matchesDate;
    }).toList();
  }

  void _openFilterSheet() {
    String? tempStatus = _statusFilter;
    String? tempPlan = _planFilter;
    DateTimeRange? tempRange = _joinDateRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros avanzados',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  // ignore: deprecated_member_use
                  value: tempStatus,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                    DropdownMenuItem(
                        value: 'Inactivo', child: Text('Inactivo')),
                    DropdownMenuItem(
                        value: 'Suspendido', child: Text('Suspendido')),
                  ],
                  onChanged: (value) => setModalState(() => tempStatus = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  // ignore: deprecated_member_use
                  value: tempPlan,
                  decoration: const InputDecoration(
                    labelText: 'Plan',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...kPlans.map((plan) => DropdownMenuItem(
                          value: plan.id,
                          child: Text(plan.name),
                        )),
                  ],
                  onChanged: (value) => setModalState(() => tempPlan = value),
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
                  trailing: tempRange != null
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setModalState(() => tempRange = null),
                        )
                      : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempStatus = null;
                          tempPlan = null;
                          tempRange = null;
                        });
                      },
                      child: const Text('Limpiar filtros'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _statusFilter = tempStatus;
                          _planFilter = tempPlan;
                          _joinDateRange = tempRange;
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
        );
      },
    );
  }

  void _exportMembers(List<Member> members) {
    final rows = members.map((member) {
      final plan = kPlans.firstWhere((p) => p.id == member.planId);
      return [
        member.id,
        member.name,
        member.email,
        member.phone,
        DateFormatter.formatDate(member.joinDate),
        member.status,
        plan.name,
      ];
    }).toList();

    DataExporter.copyAsCsv(
      context: context,
      fileName: 'socios',
      headers: [
        'ID',
        'Nombre',
        'Correo',
        'Teléfono',
        'Fecha ingreso',
        'Estado',
        'Plan'
      ],
      rows: rows,
    );
  }

  String _generateMemberId() {
    final next = _members.length + 1;
    return 'M${next.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Preparar datos para la tabla
    final columns = [
      'ID',
      'Nombre',
      'Email',
      'Teléfono',
      'Fecha Ingreso',
      'Estado',
      'Plan'
    ];
    final members = _filteredMembers;
    final rows = members.map((member) {
      final plan = kPlans.firstWhere((p) => p.id == member.planId);
      return [
        member.id,
        member.name,
        member.email,
        member.phone,
        DateFormatter.formatDate(member.joinDate),
        member.status,
        plan.name,
      ];
    }).toList();

    return AppScaffold(
      title: 'Gestión de Socios',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddMemberDialog,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberDialog,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            Icons.people_outlined,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_members.length}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Total Socios',
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
                            Icons.person_outlined,
                            size: 32,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_members.where((m) => m.status == 'Activo').length}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                          Text(
                            'Socios Activos',
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

            // Members Table
            DataTableX(
              columns: columns,
              rows: rows,
              searchHint: 'Buscar socios...',
              onSearchChanged: (value) => setState(() {
                _searchQuery = value.toLowerCase();
              }),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Abrir filtros',
                  onPressed: _openFilterSheet,
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Exportar CSV',
                  onPressed: () => _exportMembers(members),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
