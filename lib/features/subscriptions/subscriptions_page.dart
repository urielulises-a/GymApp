import 'package:flutter/material.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';
import '../../core/widgets/form_dialog.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/dates.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  String _selectedMember = 'M001';
  String _selectedPlan = 'P001';
  DateTime _startDate = DateTime.now();

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
            value: _selectedMember,
            decoration: const InputDecoration(
              labelText: 'Socio',
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
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedPlan,
            decoration: const InputDecoration(
              labelText: 'Plan',
              border: OutlineInputBorder(),
            ),
            items: kPlans.map((plan) => DropdownMenuItem(
              value: plan.id,
              child: Text('${plan.name} - ${MoneyFormatter.format(plan.price)}'),
            )).toList(),
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
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
                    Text('${kPlans.firstWhere((p) => p.id == _selectedPlan).durationDays} días'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fecha fin:'),
                    Text(DateFormatter.formatDate(
                      _startDate.add(Duration(days: kPlans.firstWhere((p) => p.id == _selectedPlan).durationDays))
                    )),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total:'),
                    Text(
                      MoneyFormatter.format(kPlans.firstWhere((p) => p.id == _selectedPlan).price),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demostración: Suscripción creada exitosamente')),
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Preparar datos para la tabla
    final columns = ['ID', 'Socio', 'Plan', 'Inicio', 'Fin', 'Estado', 'Monto'];
    final rows = kSubscriptions.map((subscription) {
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
                            '${kSubscriptions.length}',
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
                            MoneyFormatter.format(
                              kSubscriptions.fold(0.0, (sum, sub) => sum + sub.amount)
                            ),
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
