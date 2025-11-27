import 'package:flutter/material.dart';
import '../../core/models/member.dart';
import '../../core/models/plan.dart';
import '../../core/services/members_service.dart';
import '../../core/services/plans_service.dart';
import '../../core/services/http_service.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/export_utils.dart';
import '../../core/widgets/app_scaffold.dart';
import 'member_detail_page.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final _membersService = MembersService();
  final _plansService = PlansService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  List<Member> _members = [];
  List<Plan> _plans = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _statusFilter;
  String? _planFilter;
  DateTimeRange? _joinDateRange;

  String? _selectedPlanId;
  String _selectedStatus = 'Activo';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final membersResponse = await _membersService.getMembers(
        page: 1,
        limit: 1000,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _statusFilter,
        planId: _planFilter,
        fromDate: _joinDateRange?.start.toIso8601String(),
        toDate: _joinDateRange?.end.toIso8601String(),
      );

      final plansResponse = await _plansService.getPlans(
        page: 1,
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _members = membersResponse.data ?? [];
          _plans = plansResponse.data ?? [];
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

  Future<void> _createMember() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Por favor ingresa el nombre');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError('Por favor ingresa el correo');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text.trim())) {
      _showError('Por favor ingresa un correo valido');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showError('Por favor ingresa el telefono');
      return;
    }

    try {
      await _membersService.createMember(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        status: _selectedStatus,
        planId: _selectedPlanId,
      );

      _showSuccess('Socio agregado exitosamente');
      if (mounted) {
        Navigator.of(context).pop();
        _loadData();
      }
    } on ApiException catch (e) {
      _showError('Error al crear socio: ${e.message}');
    }
  }

  Future<void> _updateMember(Member member) async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Por favor ingresa el nombre');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError('Por favor ingresa el correo');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text.trim())) {
      _showError('Por favor ingresa un correo valido');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showError('Por favor ingresa el telefono');
      return;
    }

    try {
      await _membersService.updateMember(
        member.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        status: _selectedStatus,
        planId: _selectedPlanId,
      );

      _showSuccess('Socio actualizado exitosamente');
      if (mounted) {
        Navigator.of(context).pop();
        _loadData();
      }
    } on ApiException catch (e) {
      _showError('Error al actualizar socio: ${e.message}');
    }
  }

  Future<void> _toggleMemberStatus(Member member) async {
    final newStatus = member.status == 'Activo' ? 'Inactivo' : 'Activo';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member.status == 'Activo'
            ? 'Dar de baja socio'
            : 'Reactivar socio'),
        content: Text(member.status == 'Activo'
            ? '¿Estás seguro de dar de baja a ${member.name}? El socio ya no podrá acceder al gimnasio.'
            : '¿Estás seguro de reactivar a ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: member.status == 'Activo' ? Colors.red : Colors.green,
            ),
            child: Text(member.status == 'Activo' ? 'Dar de baja' : 'Reactivar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _membersService.updateMember(
        member.id,
        status: newStatus,
      );
      _showSuccess(member.status == 'Activo'
          ? 'Socio dado de baja exitosamente'
          : 'Socio reactivado exitosamente');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al cambiar estado: ${e.message}');
    }
  }

  Future<void> _deleteMember(Member member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text(
            '¿Eliminar permanentemente el socio ${member.name}?\n\nEsta acción no se puede deshacer y se eliminarán todos los datos asociados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar permanentemente'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _membersService.deleteMember(member.id);
      _showSuccess('Socio eliminado');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al eliminar: ${e.message}');
    }
  }

  Future<void> _openMemberDetail(Member member) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailPage(memberId: member.id),
      ),
    );

    if (result == 'refresh') {
      // El usuario quiere editar desde la página de detalles
      _showAddMemberDialog(member: member);
    }
  }

  void _showAddMemberDialog({Member? member}) {
    if (member == null) {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      // Usar el filtro de plan si está seleccionado, si no, usar el primer plan
      _selectedPlanId = _planFilter ?? (_plans.isNotEmpty ? _plans.first.id : null);
      _selectedStatus = 'Activo';
    } else {
      _nameController.text = member.name;
      _emailController.text = member.email;
      _phoneController.text = member.phone ?? '';
      _selectedPlanId = member.planId;
      _selectedStatus = member.status;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(member == null ? 'Agregar Nuevo Socio' : 'Editar Socio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electronico',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefono',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPlanId,
                  decoration: const InputDecoration(
                    labelText: 'Plan',
                    border: OutlineInputBorder(),
                  ),
                  items: _plans
                      .map((plan) => DropdownMenuItem(
                            value: plan.id,
                            child: Text('${plan.name} - ${plan.price}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => _selectedPlanId = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                    DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                    DropdownMenuItem(
                        value: 'Suspendido', child: Text('Suspendido')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => _selectedStatus = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (member == null) {
                  _createMember();
                } else {
                  _updateMember(member);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  List<Member> get _filteredMembers {
    return _members.where((member) {
      final matchesSearch = _searchQuery.isEmpty ||
          member.name.toLowerCase().contains(_searchQuery) ||
          member.email.toLowerCase().contains(_searchQuery) ||
          member.phone?.toLowerCase().contains(_searchQuery) == true;
      return matchesSearch;
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
                  initialValue: tempStatus,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                    DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                    DropdownMenuItem(
                        value: 'Suspendido', child: Text('Suspendido')),
                  ],
                  onChanged: (value) => setModalState(() => tempStatus = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: tempPlan,
                  decoration: const InputDecoration(
                    labelText: 'Plan',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ..._plans.map((plan) => DropdownMenuItem(
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
                        _loadData();
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
      final plan = _plans.firstWhere(
        (p) => p.id == member.planId,
        orElse: () => Plan(
          id: member.planId ?? '',
          name: 'Desconocido',
          description: '',
          price: 0,
          durationDays: 0,
          features: [],
          displayId: '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      return [
        member.id,
        member.name,
        member.email,
        member.phone ?? '',
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
        'Telefono',
        'Fecha ingreso',
        'Estado',
        'Plan'
      ],
      rows: rows,
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

    final members = _filteredMembers;

    return AppScaffold(
      title: 'Gestion de Socios',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Buscar socios por nombre, email o teléfono...',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                  ),
                                  onChanged: (value) => setState(() {
                                    _searchQuery = value.toLowerCase();
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                        ),
                        const Divider(height: 1),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final member = members[index];
                            final plan = _plans.firstWhere(
                              (p) => p.id == member.planId,
                              orElse: () => Plan(
                                id: member.planId ?? '',
                                name: 'Sin plan',
                                description: '',
                                price: 0,
                                durationDays: 0,
                                features: [],
                                displayId: '',
                                createdAt: DateTime.now().toIso8601String(),
                                updatedAt: DateTime.now().toIso8601String(),
                              ),
                            );

                            Color statusColor;
                            switch (member.status) {
                              case 'Activo':
                                statusColor = Colors.green;
                                break;
                              case 'Inactivo':
                                statusColor = Colors.red;
                                break;
                              case 'Suspendido':
                                statusColor = Colors.orange;
                                break;
                              default:
                                statusColor = Colors.grey;
                            }

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withOpacity(0.2),
                                child: Text(
                                  member.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      member.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: statusColor),
                                      ),
                                      child: Text(
                                        member.status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Email: ${member.email}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Teléfono: ${member.phone ?? 'No proporcionado'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Plan: ${plan.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Ingreso: ${DateFormatter.formatDate(member.joinDate)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              trailing: LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 300) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility),
                                          tooltip: 'Ver detalles',
                                          onPressed: () => _openMemberDetail(member),
                                          color: colorScheme.primary,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          tooltip: 'Editar',
                                          onPressed: () => _showAddMemberDialog(member: member),
                                          color: Colors.blue,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            member.status == 'Activo'
                                                ? Icons.person_remove
                                                : Icons.person_add,
                                          ),
                                          tooltip: member.status == 'Activo'
                                              ? 'Dar de baja'
                                              : 'Reactivar',
                                          onPressed: () => _toggleMemberStatus(member),
                                          color: member.status == 'Activo'
                                              ? Colors.orange
                                              : Colors.green,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          tooltip: 'Eliminar permanentemente',
                                          onPressed: () => _deleteMember(member),
                                          color: Colors.red,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return PopupMenuButton(
                                      icon: const Icon(Icons.more_vert),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.visibility, size: 20),
                                              SizedBox(width: 8),
                                              Text('Ver detalles'),
                                            ],
                                          ),
                                          onTap: () => Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () => _openMemberDetail(member),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 8),
                                              Text('Editar'),
                                            ],
                                          ),
                                          onTap: () => Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () => _showAddMemberDialog(member: member),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          child: Row(
                                            children: [
                                              Icon(
                                                member.status == 'Activo'
                                                    ? Icons.person_remove
                                                    : Icons.person_add,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(member.status == 'Activo'
                                                  ? 'Dar de baja'
                                                  : 'Reactivar'),
                                            ],
                                          ),
                                          onTap: () => Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () => _toggleMemberStatus(member),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.delete, size: 20, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                          onTap: () => Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () => _deleteMember(member),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
