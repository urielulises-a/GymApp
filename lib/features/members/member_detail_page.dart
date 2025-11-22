import 'package:flutter/material.dart';
import '../../core/models/member.dart';
import '../../core/models/subscription.dart';
import '../../core/models/payment.dart';
import '../../core/models/attendance.dart';
import '../../core/services/members_service.dart';
import '../../core/services/subscriptions_service.dart';
import '../../core/services/payments_service.dart';
import '../../core/services/attendance_service.dart';
import '../../core/services/http_service.dart';
import '../../core/utils/dates.dart';

class MemberDetailPage extends StatefulWidget {
  final String memberId;

  const MemberDetailPage({
    super.key,
    required this.memberId,
  });

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage>
    with SingleTickerProviderStateMixin {
  final _membersService = MembersService();
  final _subscriptionsService = SubscriptionsService();
  final _paymentsService = PaymentsService();
  final _attendanceService = AttendanceService();

  late TabController _tabController;

  Member? _member;
  List<Subscription> _subscriptions = [];
  List<Payment> _payments = [];
  List<Attendance> _attendances = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Cargar datos del socio
      final member = await _membersService.getMemberById(widget.memberId);

      // Cargar suscripciones del socio
      final subscriptionsResponse =
          await _subscriptionsService.getSubscriptions(
        memberId: widget.memberId,
        limit: 100,
      );

      // Cargar pagos del socio
      final paymentsResponse = await _paymentsService.getPayments(
        memberId: widget.memberId,
        limit: 100,
      );

      // Cargar asistencias del socio
      final attendanceResponse = await _attendanceService.getAttendance(
        memberId: widget.memberId,
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _member = member;
          _subscriptions = subscriptionsResponse.data ?? [];
          _payments = paymentsResponse.data ?? [];
          _attendances = attendanceResponse.data ?? [];
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

  Future<void> _toggleMemberStatus() async {
    if (_member == null) return;

    final newStatus = _member!.status == 'Activo' ? 'Inactivo' : 'Activo';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_member!.status == 'Activo'
            ? 'Dar de baja socio'
            : 'Reactivar socio'),
        content: Text(_member!.status == 'Activo'
            ? '¿Estás seguro de dar de baja a ${_member!.name}? El socio ya no podrá acceder al gimnasio.'
            : '¿Estás seguro de reactivar a ${_member!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  _member!.status == 'Activo' ? Colors.red : Colors.green,
            ),
            child: Text(_member!.status == 'Activo' ? 'Dar de baja' : 'Reactivar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _membersService.updateMember(
        widget.memberId,
        status: newStatus,
      );
      _showSuccess(_member!.status == 'Activo'
          ? 'Socio dado de baja exitosamente'
          : 'Socio reactivado exitosamente');
      _loadData();
    } on ApiException catch (e) {
      _showError('Error al cambiar estado: ${e.message}');
    }
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

  Widget _buildInfoCard() {
    if (_member == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor;
    switch (_member!.status) {
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    _member!.name.substring(0, 1).toUpperCase(),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _member!.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${_member!.displayId}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          _member!.status,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar información',
                  onPressed: () {
                    Navigator.of(context).pop('refresh');
                  },
                ),
                IconButton(
                  icon: Icon(
                    _member!.status == 'Activo'
                        ? Icons.person_remove
                        : Icons.person_add,
                  ),
                  tooltip: _member!.status == 'Activo'
                      ? 'Dar de baja'
                      : 'Reactivar',
                  onPressed: _toggleMemberStatus,
                  color: _member!.status == 'Activo' ? Colors.red : Colors.green,
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.email,
                    'Correo',
                    _member!.email,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildInfoItem(
                    Icons.phone,
                    'Teléfono',
                    _member!.phone ?? 'No proporcionado',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today,
                    'Fecha de ingreso',
                    DateFormatter.formatDate(_member!.joinDate),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildInfoItem(
                    Icons.fitness_center,
                    'Plan actual',
                    _member!.planName ?? 'Sin plan',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionsTab() {
    if (_subscriptions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.card_membership, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No hay suscripciones registradas',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _subscriptions[index];
        final isActive = subscription.status == 'Activo';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isActive ? Colors.green.shade100 : Colors.grey.shade200,
              child: Icon(
                Icons.card_membership,
                color: isActive ? Colors.green : Colors.grey,
              ),
            ),
            title: Text(
              subscription.planName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${DateFormatter.formatDate(subscription.startDate)} - ${DateFormatter.formatDate(subscription.endDate)}',
                ),
                Text('\$${subscription.amount.toStringAsFixed(2)}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                subscription.status,
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    if (_payments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payments, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No hay pagos registrados',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        final isCompleted = payment.status == 'Completado';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isCompleted ? Colors.blue.shade100 : Colors.orange.shade100,
              child: Icon(
                Icons.attach_money,
                color: isCompleted ? Colors.blue : Colors.orange,
              ),
            ),
            title: Text(
              '\$${payment.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(DateFormatter.formatDate(payment.paymentDate)),
                Text('Método: ${payment.method}'),
                if (payment.notes != null) Text('Nota: ${payment.notes}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                payment.status,
                style: TextStyle(
                  color: isCompleted ? Colors.blue : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    if (_attendances.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No hay asistencias registradas',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attendances.length,
      itemBuilder: (context, index) {
        final attendance = _attendances[index];
        final isInProgress = attendance.status == 'En curso';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isInProgress
                  ? Colors.purple.shade100
                  : Colors.green.shade100,
              child: Icon(
                isInProgress ? Icons.login : Icons.logout,
                color: isInProgress ? Colors.purple : Colors.green,
              ),
            ),
            title: Text(
              DateFormatter.formatDate(attendance.checkInTime),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Entrada: ${DateFormatter.formatTime(attendance.checkInTime)}'),
                Text(
                  attendance.checkOutTime != null
                      ? 'Salida: ${DateFormatter.formatTime(attendance.checkOutTime!)}'
                      : 'Salida: En curso',
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isInProgress
                    ? Colors.purple.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                attendance.status,
                style: TextStyle(
                  color: isInProgress ? Colors.purple : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Socio'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _member == null
              ? const Center(child: Text('No se pudo cargar la información'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildInfoCard(),
                    ),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Suscripciones', icon: Icon(Icons.card_membership)),
                        Tab(text: 'Pagos', icon: Icon(Icons.payments)),
                        Tab(text: 'Asistencias', icon: Icon(Icons.access_time)),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSubscriptionsTab(),
                          _buildPaymentsTab(),
                          _buildAttendanceTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
