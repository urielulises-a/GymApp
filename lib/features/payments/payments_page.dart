import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/payment.dart';
import '../../core/models/member.dart';
import '../../core/models/subscription.dart';
import '../../core/services/payments_service.dart';
import '../../core/services/members_service.dart';
import '../../core/services/subscriptions_service.dart';
import '../../core/services/http_service.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/export_utils.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _paymentsService = PaymentsService();
  final _membersService = MembersService();
  final _subscriptionsService = SubscriptionsService();
  final _amountController = TextEditingController();

  List<Payment> _payments = [];
  List<Member> _members = [];
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _memberFilter;
  String? _methodFilter;
  String? _statusFilter;
  DateTimeRange? _dateRange;

  String? _selectedMemberId;
  String? _selectedSubscriptionId;
  String _selectedMethod = 'Efectivo';
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final paymentsResponse = await _paymentsService.getPayments(
        page: 1,
        limit: 100,
        memberId: _memberFilter,
        method: _methodFilter,
        status: _statusFilter,
        fromDate: _dateRange?.start.toIso8601String(),
        toDate: _dateRange?.end.toIso8601String(),
      );

      final membersResponse = await _membersService.getMembers(
        page: 1,
        limit: 1000,
      );

      final subscriptionsResponse = await _subscriptionsService.getSubscriptions(
        page: 1,
        limit: 1000,
      );

      if (mounted) {
        setState(() {
          _payments = paymentsResponse.data ?? [];
          _members = membersResponse.data ?? [];
          _subscriptions = subscriptionsResponse.data ?? [];
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

  Future<void> _createPayment() async {
    if (_selectedMemberId == null || _selectedSubscriptionId == null) {
      _showError('Por favor selecciona un socio y una suscripcion');
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      _showError('Por favor ingresa un monto valido');
      return;
    }

    try {
      await _paymentsService.createPayment(
        memberId: _selectedMemberId!,
        subscriptionId: _selectedSubscriptionId!,
        amount: amount,
        paymentDate: _paymentDate.toIso8601String(),
        method: _selectedMethod,
        status: 'Completado',
      );

      _showSuccess('Pago registrado exitosamente');
      if (mounted) {
        Navigator.of(context).pop();
        _loadData();
      }
    } on ApiException catch (e) {
      _showError('Error al crear pago: ${e.message}');
    }
  }

  Future<void> _updatePayment(Payment payment, {String? status}) async {
    try {
      await _paymentsService.updatePayment(
        payment.id,
        status: status,
      );

      _showSuccess('Pago actualizado');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al actualizar: ${e.message}');
    }
  }

  Future<void> _deletePayment(Payment payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('Eliminar el pago ${payment.id}?'),
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
      await _paymentsService.deletePayment(payment.id);
      _showSuccess('Pago eliminado');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al eliminar: ${e.message}');
    }
  }

  void _showAddPaymentDialog() {
    _selectedMemberId = _members.isNotEmpty ? _members.first.id : null;
    _selectedSubscriptionId = _subscriptions.isNotEmpty ? _subscriptions.first.id : null;
    _amountController.clear();
    _selectedMethod = 'Efectivo';
    _paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar Pago'),
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
                  value: _selectedSubscriptionId,
                  decoration: const InputDecoration(
                    labelText: 'Suscripcion',
                    border: OutlineInputBorder(),
                  ),
                  items: _subscriptions.map((subscription) {
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
                    return DropdownMenuItem(
                      value: subscription.id,
                      child: Text(
                          '${member.name} - ${MoneyFormatter.format(subscription.amount)}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => _selectedSubscriptionId = value);
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
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Metodo de pago',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                    DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                    DropdownMenuItem(
                        value: 'Transferencia', child: Text('Transferencia')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => _selectedMethod = value!);
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
                      setDialogState(() => _paymentDate = date);
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: _createPayment,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  List<Payment> get _filteredPayments {
    return _payments.where((payment) {
      final matchesSearch = _searchQuery.isEmpty ||
          payment.id.toLowerCase().contains(_searchQuery);
      return matchesSearch;
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
                  value: tempMember,
                  decoration: const InputDecoration(
                    labelText: 'Socio',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ..._members.map(
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
                  value: tempMethod,
                  decoration: const InputDecoration(
                    labelText: 'Metodo de pago',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                    DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                    DropdownMenuItem(
                        value: 'Transferencia', child: Text('Transferencia')),
                  ],
                  onChanged: (value) => setModalState(() => tempMethod = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: tempStatus,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(
                        value: 'Completado', child: Text('Completado')),
                    DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
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
      ),
    );
  }

  void _exportPayments(List<Payment> payments) {
    final rows = payments.map((payment) {
      final member = _members.firstWhere(
        (m) => m.id == payment.memberId,
        orElse: () => Member(
          id: payment.memberId,
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
        payment.id,
        member.name,
        payment.subscriptionId,
        MoneyFormatter.format(payment.amount),
        DateFormatter.formatDate(payment.paymentDate),
        payment.method,
        payment.status,
      ].map((e) => e ?? '').toList();
    }).toList();

    DataExporter.copyAsCsv(
      context: context,
      fileName: 'pagos',
      headers: [
        'ID',
        'Socio',
        'Suscripcion',
        'Monto',
        'Fecha',
        'Metodo',
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
          final member = _members.firstWhere(
            (m) => m.id == payment.memberId,
            orElse: () => Member(
              id: payment.memberId,
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
    final receipt = '''
Recibo: ${payment.id}
Socio: ${member.name}
Monto: ${MoneyFormatter.format(payment.amount)}
Fecha: ${DateFormatter.formatDate(payment.paymentDate)}
Metodo: ${payment.method}
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

    final columns = [
      'ID',
      'Socio',
      'Suscripcion',
      'Monto',
      'Fecha',
      'Metodo',
      'Estado'
    ];
    final payments = _filteredPayments;
    final rows = payments.map((payment) {
      final member = _members.firstWhere(
        (m) => m.id == payment.memberId,
        orElse: () => Member(
          id: payment.memberId,
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
        payment.id,
        member.name,
        payment.subscriptionId,
        MoneyFormatter.format(payment.amount),
        DateFormatter.formatDate(payment.paymentDate),
        payment.method,
        payment.status,
      ].map((e) => e ?? '').toList();
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
