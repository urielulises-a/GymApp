import 'package:flutter/material.dart';
import '../../core/utils/dates.dart';
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
  String _language = 'es-MX';
  String _gymName = 'Gimnasio Central';
  String _gymAddress = 'Av. Siempre Viva 742, CDMX';
  String _gymPhone = '+52 55 1234 5678';
  String _gymEmail = 'contacto@gimnasio.com';
  final Map<String, _DaySchedule> _schedules = {
    'Lunes': _DaySchedule(
        open: const TimeOfDay(hour: 6, minute: 0),
        close: const TimeOfDay(hour: 22, minute: 0)),
    'Martes': _DaySchedule(
        open: const TimeOfDay(hour: 6, minute: 0),
        close: const TimeOfDay(hour: 22, minute: 0)),
    'Miércoles': _DaySchedule(
        open: const TimeOfDay(hour: 6, minute: 0),
        close: const TimeOfDay(hour: 22, minute: 0)),
    'Jueves': _DaySchedule(
        open: const TimeOfDay(hour: 6, minute: 0),
        close: const TimeOfDay(hour: 22, minute: 0)),
    'Viernes': _DaySchedule(
        open: const TimeOfDay(hour: 6, minute: 0),
        close: const TimeOfDay(hour: 22, minute: 0)),
    'Sábado': _DaySchedule(
        open: const TimeOfDay(hour: 8, minute: 0),
        close: const TimeOfDay(hour: 18, minute: 0)),
    'Domingo': _DaySchedule(
        open: const TimeOfDay(hour: 9, minute: 0),
        close: const TimeOfDay(hour: 14, minute: 0)),
  };
  final Set<String> _paymentMethods = {'Efectivo', 'Tarjeta'};
  DateTime? _lastBackup;
  bool _autoBackup = true;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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
                          const SnackBar(
                              content: Text('Demostración: Tema cambiado')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Idioma'),
                      subtitle: Text(_language),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _showLanguageSelector,
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
                      subtitle:
                          const Text('Recibir notificaciones del sistema'),
                      value: _notifications,
                      onChanged: (value) {
                        setState(() {
                          _notifications = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Notificaciones por Email'),
                      subtitle: const Text(
                          'Recibir notificaciones por correo electrónico'),
                      value: _emailNotifications,
                      onChanged: _notifications
                          ? (value) {
                              setState(() {
                                _emailNotifications = value;
                              });
                            }
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('Notificaciones por SMS'),
                      subtitle: const Text(
                          'Recibir notificaciones por mensaje de texto'),
                      value: _smsNotifications,
                      onChanged: _notifications
                          ? (value) {
                              setState(() {
                                _smsNotifications = value;
                              });
                            }
                          : null,
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
                      subtitle: Text('$_gymName · $_gymPhone'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _editGymInfo,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Horarios de Operación'),
                      subtitle: Text(
                        '${_schedules.entries.first.value.format(context)} - ${_schedules.entries.first.value.format(context, closing: true)} · 7 días',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _editSchedules,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.payment),
                      title: const Text('Configuración de Pagos'),
                      subtitle: Text(_paymentMethods.join(', ')),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _editPaymentMethods,
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
                      subtitle: Text(
                        _lastBackup == null
                            ? 'Nunca se ha generado un respaldo'
                            : 'Último: ${DateFormatter.formatDateTime(_lastBackup!)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _createBackup,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.update),
                      title: const Text('Actualizaciones'),
                      subtitle:
                          const Text('Verificar actualizaciones del sistema'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Sistema actualizado - Versión 1.0.0')),
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
                          applicationIcon:
                              const Icon(Icons.fitness_center, size: 48),
                          children: [
                            const Text(
                                'Aplicación web para la gestión completa de un gimnasio.'),
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
                      leading: Icon(Icons.logout,
                          color: colorScheme.onErrorContainer),
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
                            content: const Text(
                                '¿Estás seguro de que quieres cerrar sesión?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Demostración: Sesión cerrada')),
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

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Seleccionar idioma'),
        children: [
          _buildLanguageOption(context, 'es-MX', 'Español (México)'),
          _buildLanguageOption(context, 'es-ES', 'Español (España)'),
          _buildLanguageOption(context, 'en-US', 'Inglés'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String code, String label) {
    return RadioListTile<String>(
      value: code,
      // ignore: deprecated_member_use
      groupValue: _language,
      title: Text(label),
      // ignore: deprecated_member_use
      onChanged: (value) {
        setState(() => _language = value!);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Idioma actualizado a $label')),
        );
      },
    );
  }

  void _editGymInfo() {
    _nameController.text = _gymName;
    _addressController.text = _gymAddress;
    _phoneController.text = _gymPhone;
    _emailController.text = _gymEmail;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información del gimnasio'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
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
              setState(() {
                _gymName = _nameController.text.trim();
                _gymAddress = _addressController.text.trim();
                _gymPhone = _phoneController.text.trim();
                _gymEmail = _emailController.text.trim();
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Información actualizada')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editSchedules() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Horarios de operación',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._schedules.entries.map(
              (entry) => ListTile(
                title: Text(entry.key),
                subtitle: Text(
                  '${entry.value.format(context)} - ${entry.value.format(context, closing: true)}',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final updated = await _pickSchedule(entry.value);
                  if (updated != null) {
                    setModalState(() {
                      entry.value.open = updated.open;
                      entry.value.close = updated.close;
                    });
                    setState(() {});
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Respaldos automáticos diarios'),
              value: _autoBackup,
              onChanged: (value) {
                setModalState(() => _autoBackup = value);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<_DaySchedule?> _pickSchedule(_DaySchedule schedule) async {
    final open = await showTimePicker(
      context: context,
      initialTime: schedule.open,
    );
    if (open == null) return null;
    final close = await showTimePicker(
      context: context,
      initialTime: schedule.close,
    );
    if (close == null) return null;
    return _DaySchedule(open: open, close: close);
  }

  void _editPaymentMethods() {
    final options = ['Efectivo', 'Tarjeta', 'Transferencia', 'Depósito'];
    final temp = Set<String>.from(_paymentMethods);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Métodos aceptados'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((method) {
              return CheckboxListTile(
                value: temp.contains(method),
                title: Text(method),
                onChanged: (value) {
                  setModalState(() {
                    if (value == true) {
                      temp.add(method);
                    } else {
                      temp.remove(method);
                    }
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (temp.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Selecciona al menos un método')),
                  );
                  return;
                }
                setState(() {
                  _paymentMethods
                    ..clear()
                    ..addAll(temp);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creando respaldo...')),
    );
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _lastBackup = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Respaldo completado: ${DateFormatter.formatDateTime(_lastBackup!)}'),
      ),
    );
  }
}

extension on _DaySchedule {
  String format(BuildContext context, {bool closing = false}) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(closing ? close : open,
        alwaysUse24HourFormat: true);
  }
}

class _DaySchedule {
  TimeOfDay open;
  TimeOfDay close;

  _DaySchedule({required this.open, required this.close});
}
