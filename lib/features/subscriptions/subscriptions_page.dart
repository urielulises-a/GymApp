import 'package:flutter/material.dart';
import '../../core/models/subscription.dart';
import '../../core/models/member.dart';
import '../../core/models/plan.dart';
import '../../core/services/subscriptions_service.dart';
import '../../core/services/members_service.dart';
import '../../core/services/plans_service.dart';
import '../../core/services/http_service.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/export_utils.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final _subscriptionsService = SubscriptionsService();
  final _membersService = MembersService();
  final _plansService = PlansService();

  List<Subscription> _subscriptions = [];
  List<Member> _members = [];
  List<Plan> _plans = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _statusFilter;
  String? _planFilter;
  DateTimeRange? _dateRange;

  String? _selectedMemberId;
  String? _selectedPlanId;
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final subscriptionsResponse = await _subscriptionsService.getSubscriptions(
        page: 1,
        limit: 100,
        status: _statusFilter,
        planId: _planFilter,
        fromDate: _dateRange?.start.toIso8601String(),
        toDate: _dateRange?.end.toIso8601String(),
      );

      final membersResponse = await _membersService.getMembers(
        page: 1,
        limit: 1000,
      );

      final plansResponse = await _plansService.getPlans(
        page: 1,
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _subscriptions = subscriptionsResponse.data ?? [];
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

  Future<void> _createSubscription() async {
    if (_selectedMemberId == null || _selectedPlanId == null) {
      _showError('Por favor selecciona un socio y un plan');
      return;
    }

    try {
      await _subscriptionsService.createSubscription(
        memberId: _selectedMemberId!,
        planId: _selectedPlanId!,
        startDate: _startDate.toIso8601String(),
      );

      _showSuccess('Suscripcion creada exitosamente');
      if (mounted) {
        Navigator.of(context).pop();
        _loadData();
      }
    } on ApiException catch (e) {
      _showError('Error al crear suscripcion: ${e.message}');
    }
  }

  Future<void> _updateSubscription(Subscription subscription, String status) async {
    try {
      await _subscriptionsService.updateSubscription(
        subscription.id,
        status: status,
      );

      _showSuccess('Suscripcion actualizada');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al actualizar: ${e.message}');
    }
  }

  Future<void> _deleteSubscription(Subscription subscription) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('Eliminar la suscripcion ${subscription.id}?'),
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
      await _subscriptionsService.deleteSubscription(subscription.id);
      _showSuccess('Suscripcion eliminada');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al eliminar: ${e.message}');
    }
  }

  void _showAddSubscriptionDialog() {
    _selectedMemberId = _members.isNotEmpty ? _members.first.id : null;
    _selectedPlanId = _plans.isNotEmpty ? _plans.first.id : null;
    _startDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nueva Suscripcion'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedMemberId,
                  decoration: const InputDecoration(
                    labelText: 'Socio',
                    border: OutlineInputBorder(),
                  ),
                  items: _members
                      .map((member) => DropdownMenuItem(
                            value: member.id,
                            child: Text(member.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => _selectedMemberId = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPlanId,
                  decoration: const InputDecoration(
                    labelText: 'Plan',
                    border: OutlineInputBorder(),
                  ),
                  items: _plans
                      .map((plan) => DropdownMenuItem(
                            value: plan.id,
                            child: Text(
                                '${plan.name} - ${MoneyFormatter.format(plan.price)}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => _selectedPlanId = value);
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => _startDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de inicio',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormatter.formatDate(_startDate)),
                  ),
                ),
                if (_selectedPlanId != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        final plan = _plans.firstWhere((p) => p.id == _selectedPlanId);
                        final endDate = _startDate.add(Duration(days: plan.durationDays));
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen de Suscripcion',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Duracion:'),
                                Text('${plan.durationDays} dias'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Fecha fin:'),
                                Text(DateFormatter.formatDate(endDate)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total:'),
                                Text(
                                  MoneyFormatter.format(plan.price),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: _createSubscription,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  List<Subscription> get _filteredSubscriptions {
    return _subscriptions.where((subscription) {
      final matchesSearch = _searchQuery.isEmpty ||
          subscription.id.toLowerCase().contains(_searchQuery);
      return matchesSearch;
    }).toList();
  }

  void _openFilterSheet() {
    String? tempStatus = _statusFilter;
    String? tempPlan = _planFilter;
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
                  DropdownMenuItem(value: 'Activa', child: Text('Activa')),
                  DropdownMenuItem(value: 'Vencida', child: Text('Vencida')),
                  DropdownMenuItem(value: 'Cancelada', child: Text('Cancelada')),
                ],
                onChanged: (value) => setModalState(() => tempStatus = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: tempPlan,
                decoration: const InputDecoration(
                  labelText: 'Plan',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ..._plans.map(
                    (plan) => DropdownMenuItem(
                      value: plan.id,
                      child: Text(plan.name),
                    ),
                  ),
                ],
                onChanged: (value) => setModalState(() => tempPlan = value),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range),
                title: const Text('Rango de inicio'),
                subtitle: Text(
                  tempRange == null
                      ? 'Sin filtro'
                      : '${DateFormatter.formatDate(tempRange!.start)} - ${DateFormatter.formatDate(tempRange!.end)}',
                ),
                onTap: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
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
                        tempPlan = null;
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
                        _planFilter = tempPlan;
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

  void _exportSubscriptions(List<Subscription> subscriptions) {
    final rows = subscriptions.map((subscription) {
      final member = _members.firstWhere(
        (m) => m.id == subscription.memberId,
        orElse: () => Member(
          id: subscription.memberId,
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
      final plan = _plans.firstWhere(
        (p) => p.id == subscription.planId,
        orElse: () => Plan(
          id: subscription.planId,
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
        subscription.id,
        member.name,
        plan.name,
        DateFormatter.formatDate(subscription.startDate),
        DateFormatter.formatDate(subscription.endDate),
        subscription.status,
        MoneyFormatter.format(subscription.amount),
      ].map((e) => e ?? '').toList();
    }).toList();

    DataExporter.copyAsCsv(
      context: context,
      fileName: 'suscripciones',
      headers: ['ID', 'Socio', 'Plan', 'Inicio', 'Fin', 'Estado', 'Monto'],
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

    final columns = ['ID', 'Socio', 'Plan', 'Inicio', 'Fin', 'Estado', 'Monto'];
    final subscriptions = _filteredSubscriptions;
    final rows = subscriptions.map((subscription) {
      final member = _members.firstWhere(
        (m) => m.id == subscription.memberId,
        orElse: () => Member(
          id: subscription.memberId,
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
      final plan = _plans.firstWhere(
        (p) => p.id == subscription.planId,
        orElse: () => Plan(
          id: subscription.planId,
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
        subscription.id,
        member.name,
        plan.name,
        DateFormatter.formatDate(subscription.startDate),
        DateFormatter.formatDate(subscription.endDate),
        subscription.status,
        MoneyFormatter.format(subscription.amount),
      ].map((e) => e ?? '').toList();
    }).toList();

    return AppScaffold(
      title: 'Suscripciones',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddSubscriptionDialog,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubscriptionDialog,
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
                                  Icons.subscriptions_outlined,
                                  size: 32,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_subscriptions.length}',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'Suscripciones Activas',
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
                                  Icons.attach_money_outlined,
                                  size: 32,
                                  color: colorScheme.secondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  MoneyFormatter.format(_subscriptions.fold(
                                      0.0, (sum, sub) => sum + sub.amount)),
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                                Text(
                                  'Ingresos Totales',
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
                    searchHint: 'Buscar suscripciones...',
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
                        onPressed: () => _exportSubscriptions(subscriptions),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
