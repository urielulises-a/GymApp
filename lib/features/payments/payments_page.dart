import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/dates.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/export_utils.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';
import '../../core/widgets/form_dialog.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  late final List<Payment> _payments;
  String _selectedMember = 'M001';
  String _selectedSubscription = 'S001';
  final _amountController = TextEditingController();
  String _selectedMethod = 'Efectivo';
  DateTime _paymentDate = DateTime.now();
  String _searchQuery = '';
  String? _memberFilter;
  String? _methodFilter;
  String? _statusFilter;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _payments = List<Payment>.from(kPayments);
  }

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
            value: _selectedSubscription,
            decoration: const InputDecoration(
              labelText: 'Suscripción',
              border: OutlineInputBorder(),
            ),
            items: kSubscriptions.map((subscription) {
              final member =
                  kMembers.firstWhere((m) => m.id == subscription.memberId);
              return DropdownMenuItem(
                value: subscription.id,
                child: Text(
                    '${member.name} - ${MoneyFormatter.format(subscription.amount)}'),
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
            // ignore: deprecated_member_use
            value: _selectedMethod,
            decoration: const InputDecoration(
              labelText: 'Método de pago',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
              DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
              DropdownMenuItem(
                  value: 'Transferencia', child: Text('Transferencia')),
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
          final amount =
              double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
          final payment = Payment(
            id: _generatePaymentId(),
            memberId: _selectedMember,
            subscriptionId: _selectedSubscription,
            amount: amount,
            paymentDate: _paymentDate,
            method: _selectedMethod,
            status: 'Completado',
          );

          setState(() {
            _payments.add(payment);
          });

          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pago registrado')),
            );
          }
        },
      ),
    );
  }

  List<Payment> get _filteredPayments {
    return _payments.where((payment) {
      final member = kMembers.firstWhere((m) => m.id == payment.memberId);
      final matchesSearch = _searchQuery.isEmpty ||
          member.name.toLowerCase().contains(_searchQuery) ||
          payment.id.toLowerCase().contains(_searchQuery);
      final matchesMember =
          _memberFilter == null || payment.memberId == _memberFilter;
      final matchesMethod =
          _methodFilter == null || payment.method == _methodFilter;
      final matchesStatus =
          _statusFilter == null || payment.status == _statusFilter;
      final matchesDate = _dateRange == null ||
          (payment.paymentDate.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1))) &&
              payment.paymentDate
                  .isBefore(_dateRange!.end.add(const Duration(days: 1))));
      return matchesSearch &&
          matchesMember &&
          matchesMethod &&
          matchesStatus &&
          matchesDate;
    }).toList();
  }

  void _openFilterSheet() {
    String? tempMember = _memberFilter;
    String? tempMethod = _methodFilter;
    String? tempStatus = _statusFilter;
    DateTimeRange? tempRange = _dateRange;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: StatefulBuilder(
          builder: (context, setModalState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String?>(
                  // ignore: deprecated_member_use
                  value: tempMember,
                  decoration: const InputDecoration(
                    labelText: 'Socio',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...kMembers.map(
                      (member) => DropdownMenuItem(
                        value: member.id,
                        child: Text(member.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setModalState(() => tempMember = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  // ignore: deprecated_member_use
                  value: tempMethod,
                  decoration: const InputDecoration(
                    labelText: 'Método de pago',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(
                        value: 'Efectivo', child: Text('Efectivo')),
                    DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                    DropdownMenuItem(
                        value: 'Transferencia', child: Text('Transferencia')),
                  ],
                  onChanged: (value) => setModalState(() => tempMethod = value),
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
                    DropdownMenuItem(
                        value: 'Completado', child: Text('Completado')),
                    DropdownMenuItem(
                        value: 'Pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'Fallido', child: Text('Fallido')),
                  ],
                  onChanged: (value) => setModalState(() => tempStatus = value),
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
                          tempMember = null;
                          tempMethod = null;
                          tempStatus = null;
                          tempRange = null;
                        });
                      },
                      child: const Text('Limpiar'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _memberFilter = tempMember;
                          _methodFilter = tempMethod;
                          _statusFilter = tempStatus;
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
      ),
    );
  }

  void _exportPayments(List<Payment> payments) {
    final rows = payments.map((payment) {
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

    DataExporter.copyAsCsv(
      context: context,
      fileName: 'pagos',
      headers: [
        'ID',
        'Socio',
        'Suscripción',
        'Monto',
        'Fecha',
        'Método',
        'Estado'
      ],
      rows: rows,
    );
  }

  void _showReceiptCenter() {
    final payments = _filteredPayments;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: payments.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final payment = payments[index];
          final member = kMembers.firstWhere((m) => m.id == payment.memberId);
          return ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text('Recibo ${payment.id}'),
            subtitle: Text(
                '${member.name} · ${MoneyFormatter.format(payment.amount)}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).pop();
              _showReceiptDialog(payment, member);
            },
          );
        },
      ),
    );
  }

  void _showReceiptDialog(Payment payment, Member member) {
    final subscription =
        kSubscriptions.firstWhere((s) => s.id == payment.subscriptionId);
    final plan = kPlans.firstWhere((p) => p.id == subscription.planId);
    final receipt = '''
Recibo: ${payment.id}
Socio: ${member.name}
Plan: ${plan.name}
Monto: ${MoneyFormatter.format(payment.amount)}
Fecha: ${DateFormatter.formatDate(payment.paymentDate)}
Método: ${payment.method}
Estado: ${payment.status}
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recibo de pago'),
        content: Text(receipt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: receipt));
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Recibo ${payment.id} copiado')),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  String _generatePaymentId() {
    final next = _payments.length + 1;
    return 'PAY${next.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final columns = [
      'ID',
      'Socio',
      'Suscripción',
      'Monto',
      'Fecha',
      'Método',
      'Estado'
    ];
    final payments = _filteredPayments;
    final rows = payments.map((payment) {
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
          tooltip: 'Centro de recibos',
          onPressed: _showReceiptCenter,
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
                            '${_payments.length}',
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
                              _payments.fold(
                                  0.0, (sum, payment) => sum + payment.amount),
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
            DataTableX(
              columns: columns,
              rows: rows,
              searchHint: 'Buscar pagos...',
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
                  onPressed: () => _exportPayments(payments),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
