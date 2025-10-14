import 'package:flutter/material.dart';
import '../../core/widgets/app_scaffold.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppScaffold(
      title: 'Configuración',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apariencia',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Modo Oscuro'),
                      subtitle: const Text('Cambiar entre tema claro y oscuro'),
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() {
                          _darkMode = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demostración: Tema cambiado')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Idioma'),
                      subtitle: const Text('Español (México)'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de idiomas en desarrollo')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notifications Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notificaciones',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Notificaciones Generales'),
                      subtitle: const Text('Recibir notificaciones del sistema'),
                      value: _notifications,
                      onChanged: (value) {
                        setState(() {
                          _notifications = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Notificaciones por Email'),
                      subtitle: const Text('Recibir notificaciones por correo electrónico'),
                      value: _emailNotifications,
                      onChanged: _notifications ? (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                      } : null,
                    ),
                    SwitchListTile(
                      title: const Text('Notificaciones por SMS'),
                      subtitle: const Text('Recibir notificaciones por mensaje de texto'),
                      value: _smsNotifications,
                      onChanged: _notifications ? (value) {
                        setState(() {
                          _smsNotifications = value;
                        });
                      } : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gym Settings Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuración del Gimnasio',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('Información del Gimnasio'),
                      subtitle: const Text('Nombre, dirección, teléfono'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de información en desarrollo')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Horarios de Operación'),
                      subtitle: const Text('Configurar horarios de apertura y cierre'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de horarios en desarrollo')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.payment),
                      title: const Text('Configuración de Pagos'),
                      subtitle: const Text('Métodos de pago aceptados'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de pagos en desarrollo')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // System Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sistema',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.backup),
                      title: const Text('Respaldo de Datos'),
                      subtitle: const Text('Crear respaldo de la información'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de respaldo en desarrollo')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.update),
                      title: const Text('Actualizaciones'),
                      subtitle: const Text('Verificar actualizaciones del sistema'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sistema actualizado - Versión 1.0.0')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Acerca de'),
                      subtitle: const Text('Información de la aplicación'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Sistema de Gestión de Gimnasio',
                          applicationVersion: '1.0.0',
                          applicationIcon: const Icon(Icons.fitness_center, size: 48),
                          children: [
                            const Text('Aplicación web para la gestión completa de un gimnasio.'),
                            const SizedBox(height: 16),
                            const Text('Desarrollado con Flutter Web'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Danger Zone
            Card(
              color: colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zona de Peligro',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.logout, color: colorScheme.onErrorContainer),
                      title: Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                      subtitle: Text(
                        'Cerrar sesión actual',
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cerrar Sesión'),
                            content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Demostración: Sesión cerrada')),
                                  );
                                },
                                child: const Text('Cerrar Sesión'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
