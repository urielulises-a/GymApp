import 'package:flutter/material.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/data_table_x.dart';
import '../../core/widgets/form_dialog.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/dates.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedPlan = 'P001';
  String _selectedStatus = 'Activo';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showAddMemberDialog() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _selectedPlan = 'P001';
    _selectedStatus = 'Activo';

    showDialog(
      context: context,
      builder: (context) => FormDialog(
        title: 'Agregar Nuevo Socio',
        fields: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el correo';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Por favor ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el teléfono';
              }
              return null;
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
              child: Text('${plan.name} - ${plan.price}'),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPlan = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Estado',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Activo', child: Text('Activo')),
              DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
              DropdownMenuItem(value: 'Suspendido', child: Text('Suspendido')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
        ],
        onSave: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demostración: Socio agregado exitosamente')),
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
    final columns = ['ID', 'Nombre', 'Email', 'Teléfono', 'Fecha Ingreso', 'Estado', 'Plan'];
    final rows = kMembers.map((member) {
      final plan = kPlans.firstWhere((p) => p.id == member.planId);
      return [
        member.id,
        member.name,
        member.email,
        member.phone,
        DateFormatter.formatDate(member.joinDate),
        member.status,
        plan.name,
      ];
    }).toList();

    return AppScaffold(
      title: 'Gestión de Socios',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddMemberDialog,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberDialog,
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
                            Icons.people_outlined,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${kMembers.length}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Total Socios',
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
                            Icons.person_outlined,
                            size: 32,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${kMembers.where((m) => m.status == 'Activo').length}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                          Text(
                            'Socios Activos',
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

            // Members Table
            DataTableX(
              columns: columns,
              rows: rows,
              searchHint: 'Buscar socios...',
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
