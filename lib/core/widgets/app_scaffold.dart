import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context, colorScheme),
            tooltip: 'Notificaciones',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => _showProfileMenu(context),
            tooltip: 'Perfil',
          ),
          if (actions != null) ...actions!,
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistema de Gestión',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'de Gimnasio',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outlined),
              title: const Text('Gestión de Socios'),
              onTap: () {
                Navigator.pop(context);
                context.go('/members');
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_membership_outlined),
              title: const Text('Membresías'),
              onTap: () {
                Navigator.pop(context);
                context.go('/plans');
              },
            ),
            ListTile(
              leading: const Icon(Icons.subscriptions_outlined),
              title: const Text('Suscripciones'),
              onTap: () {
                Navigator.pop(context);
                context.go('/subscriptions');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: const Text('Control de Pagos'),
              onTap: () {
                Navigator.pop(context);
                context.go('/payments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time_outlined),
              title: const Text('Asistencia'),
              onTap: () {
                Navigator.pop(context);
                context.go('/attendance');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Reportes y Estadísticas'),
              onTap: () {
                Navigator.pop(context);
                context.go('/reports');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                context.go('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

void _showNotifications(BuildContext context, ColorScheme colorScheme) {
  final notifications = [
    {
      'title': 'Pago confirmado',
      'subtitle': 'María García registró un pago',
      'time': 'Hace 5 min',
      'icon': Icons.payments_outlined,
      'color': colorScheme.primary,
    },
    {
      'title': 'Nueva asistencia',
      'subtitle': 'Juan Pérez hizo check-in',
      'time': 'Hace 12 min',
      'icon': Icons.login_outlined,
      'color': colorScheme.secondary,
    },
    {
      'title': 'Plan por vencer',
      'subtitle': 'Carlos López finaliza en 3 días',
      'time': 'Hace 1 hora',
      'icon': Icons.warning_amber_outlined,
      'color': colorScheme.tertiary,
    },
  ];

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Centro de notificaciones',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...notifications.map(
            (notification) => ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    (notification['color'] as Color).withValues(alpha: 0.15),
                child: Icon(
                  notification['icon'] as IconData,
                  color: notification['color'] as Color,
                ),
              ),
              title: Text(notification['title'] as String),
              subtitle: Text(notification['subtitle'] as String),
              trailing: Text(notification['time'] as String),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.done_all),
            label: const Text('Marcar como leído'),
          ),
        ],
      ),
    ),
  );
}

void _showProfileMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 36,
            child: Icon(Icons.account_circle, size: 48),
          ),
          const SizedBox(height: 12),
          Text(
            'Administrador General',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'admin@gimnasio.com',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Cerrar sesión'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
          ),
        ],
      ),
    ),
  );
}
