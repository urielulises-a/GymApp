import 'package:flutter/material.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/export_utils.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';
import '../../core/widgets/form_dialog.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  late final List<Subscription> _subscriptions;
  String _selectedMember = 'M001';
  String _selectedPlan = 'P001';
  DateTime _startDate = DateTime.now();
  String _searchQuery = '';
  String? _statusFilter;
  String? _planFilter;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _subscriptions = List<Subscription>.from(kSubscriptions);
  }

  void _showAddSubscriptionDialog() {
    _selectedMember = 'M001';
    _selectedPlan = 'P001';
    _startDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => FormDialog(
        title: 'Nueva Suscripción',
        fields: [
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _selectedMember,
            decoration: const InputDecoration(
              labelText: 'Socio',
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
                      child: Text(
                          '${plan.name} - ${MoneyFormatter.format(plan.price)}'),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedPlan = value!;
              });
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
                setState(() {
                  _startDate = date;
                });
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen de Suscripción',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Duración:'),
                    Text(
                        '${kPlans.firstWhere((p) => p.id == _selectedPlan).durationDays} días'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fecha fin:'),
                    Text(DateFormatter.formatDate(_startDate.add(Duration(
                        days: kPlans
                            .firstWhere((p) => p.id == _selectedPlan)
                            .durationDays)))),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:'),
                    Text(
                      MoneyFormatter.format(kPlans
                          .firstWhere((p) => p.id == _selectedPlan)
                          .price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        onSave: () {
          final plan = kPlans.firstWhere((p) => p.id == _selectedPlan);
          final subscription = Subscription(
            id: _generateSubscriptionId(),
            memberId: _selectedMember,
            planId: _selectedPlan,
            startDate: _startDate,
            endDate: _startDate.add(Duration(days: plan.durationDays)),
            status: 'Activa',
            amount: plan.price,
          );

          setState(() {
            _subscriptions.add(subscription);
          });

          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Suscripción registrada')),
            );
          }
        },
      ),
    );
  }

  List<Subscription> get _filteredSubscriptions {
    return _subscriptions.where((subscription) {
      final member = kMembers.firstWhere((m) => m.id == subscription.memberId);
      final plan = kPlans.firstWhere((p) => p.id == subscription.planId);
      final matchesSearch = _searchQuery.isEmpty ||
          member.name.toLowerCase().contains(_searchQuery) ||
          plan.name.toLowerCase().contains(_searchQuery) ||
          subscription.id.toLowerCase().contains(_searchQuery);
      final matchesStatus =
          _statusFilter == null || subscription.status == _statusFilter;
      final matchesPlan =
          _planFilter == null || subscription.planId == _planFilter;
      final matchesDates = _dateRange == null ||
          (subscription.startDate.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1))) &&
              subscription.startDate
                  .isBefore(_dateRange!.end.add(const Duration(days: 1))));
      return matchesSearch && matchesStatus && matchesPlan && matchesDates;
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
                // ignore: deprecated_member_use
                value: tempStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todos')),
                  DropdownMenuItem(value: 'Activa', child: Text('Activa')),
                  DropdownMenuItem(value: 'Vencida', child: Text('Vencida')),
                  DropdownMenuItem(
                      value: 'Cancelada', child: Text('Cancelada')),
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
                  ...kPlans.map(
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
                      : '${DateFormatter.formatDate(tempRange!.start)} — ${DateFormatter.formatDate(tempRange!.end)}',
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
      final member = kMembers.firstWhere((m) => m.id == subscription.memberId);
      final plan = kPlans.firstWhere((p) => p.id == subscription.planId);
      return [
        subscription.id,
        member.name,
        plan.name,
        DateFormatter.formatDate(subscription.startDate),
        DateFormatter.formatDate(subscription.endDate),
        subscription.status,
        MoneyFormatter.format(subscription.amount),
      ];
    }).toList();

    DataExporter.copyAsCsv(
      context: context,
      fileName: 'suscripciones',
      headers: ['ID', 'Socio', 'Plan', 'Inicio', 'Fin', 'Estado', 'Monto'],
      rows: rows,
    );
  }

  String _generateSubscriptionId() {
    final next = _subscriptions.length + 1;
    return 'S${next.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Preparar datos para la tabla
    final columns = ['ID', 'Socio', 'Plan', 'Inicio', 'Fin', 'Estado', 'Monto'];
    final subscriptions = _filteredSubscriptions;
    final rows = subscriptions.map((subscription) {
      final member = kMembers.firstWhere((m) => m.id == subscription.memberId);
      final plan = kPlans.firstWhere((p) => p.id == subscription.planId);
      return [
        subscription.id,
        member.name,
        plan.name,
        DateFormatter.formatDate(subscription.startDate),
        DateFormatter.formatDate(subscription.endDate),
        subscription.status,
        MoneyFormatter.format(subscription.amount),
      ];
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

            // Subscriptions Table
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
