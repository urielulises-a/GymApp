import 'package:flutter/material.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';
import '../../core/widgets/form_dialog.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/dates.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String _selectedMember = 'M001';
  String _selectedSubscription = 'S001';
  final _amountController = TextEditingController();
  String _selectedMethod = 'Efectivo';
  DateTime _paymentDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showAddPaymentDialog() {
    _selectedMember = 'M001';
    _selectedSubscription = 'S001';
    _amountController.clear();
    _selectedMethod = 'Efectivo';
    _paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => FormDialog(
        title: 'Registrar Pago',
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
            value: _selectedSubscription,
            decoration: const InputDecoration(
              labelText: 'Suscripción',
              border: OutlineInputBorder(),
            ),
            items: kSubscriptions.map((subscription) {
              final member = kMembers.firstWhere((m) => m.id == subscription.memberId);
              return DropdownMenuItem(
                value: subscription.id,
                child: Text('${member.name} - ${MoneyFormatter.format(subscription.amount)}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubscription = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monto',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el monto';
              }
              if (double.tryParse(value) == null) {
                return 'Por favor ingresa un monto válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedMethod,
            decoration: const InputDecoration(
              labelText: 'Método de pago',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
              DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
              DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedMethod = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _paymentDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _paymentDate = date;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha de pago',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(DateFormatter.formatDate(_paymentDate)),
            ),
          ),
        ],
        onSave: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demostración: Pago registrado exitosamente')),
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
    final columns = ['ID', 'Socio', 'Suscripción', 'Monto', 'Fecha', 'Método', 'Estado'];
    final rows = kPayments.map((payment) {
      final member = kMembers.firstWhere((m) => m.id == payment.memberId);
      return [
        payment.id,
        member.name,
        payment.subscriptionId,
        MoneyFormatter.format(payment.amount),
        DateFormatter.formatDate(payment.paymentDate),
        payment.method,
        payment.status,
      ];
    }).toList();

    return AppScaffold(
      title: 'Control de Pagos',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddPaymentDialog,
        ),
        IconButton(
          icon: const Icon(Icons.receipt_long),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funcionalidad de recibos en desarrollo')),
            );
          },
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaymentDialog,
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
                            Icons.payment_outlined,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${kPayments.length}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Pagos Registrados',
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
                              kPayments.fold(0.0, (sum, payment) => sum + payment.amount)
                            ),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                          Text(
                            'Total Cobrado',
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

            // Payments Table
            DataTableX(
              columns: columns,
              rows: rows,
              searchHint: 'Buscar pagos...',
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
