import 'package:flutter/material.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/form_dialog.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  late final List<Plan> _plans;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _featuresController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _plans = List<Plan>.from(kPlans);
  }

  void _showPlanDialog({Plan? plan}) {
    if (plan == null) {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _durationController.clear();
      _featuresController.clear();
    } else {
      _nameController.text = plan.name;
      _descriptionController.text = plan.description;
      _priceController.text = plan.price.toStringAsFixed(2);
      _durationController.text = plan.durationDays.toString();
      _featuresController.text = plan.features.join(', ');
    }

    showDialog(
      context: context,
      builder: (context) => FormDialog(
        title: plan == null ? 'Agregar Nueva Membresía' : 'Editar Membresía',
        fields: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del plan',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el nombre del plan';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la descripción';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Precio mensual',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el precio';
              }
              if (double.tryParse(value) == null) {
                return 'Por favor ingresa un precio válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Duración en días',
              border: OutlineInputBorder(),
              suffixText: 'días',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la duración';
              }
              if (int.tryParse(value) == null) {
                return 'Por favor ingresa una duración válida';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _featuresController,
            decoration: const InputDecoration(
              labelText: 'Características (separadas por coma)',
              border: OutlineInputBorder(),
              hintText: 'Acceso,Clases,Nutrición',
            ),
          ),
        ],
        onSave: () {
          final planFeatures = _featuresController.text
              .split(',')
              .map((feature) => feature.trim())
              .where((feature) => feature.isNotEmpty)
              .toList();
          final parsedPrice =
              double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;
          final parsedDuration = int.tryParse(_durationController.text) ?? 30;

          final newPlan = Plan(
            id: plan?.id ?? _generatePlanId(),
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: parsedPrice,
            durationDays: parsedDuration,
            features:
                planFeatures.isEmpty ? ['Acceso al gimnasio'] : planFeatures,
          );

          setState(() {
            if (plan == null) {
              _plans.add(newPlan);
            } else {
              final index = _plans.indexWhere((p) => p.id == plan.id);
              if (index != -1) {
                _plans[index] = newPlan;
              }
            }
          });

          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(plan == null ? 'Plan creado' : 'Plan actualizado'),
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(Plan plan) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Eliminar plan',
        content: 'Esta acción eliminará "${plan.name}". ¿Deseas continuar?',
        onConfirm: () {
          setState(() {
            _plans.removeWhere((p) => p.id == plan.id);
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Plan ${plan.name} eliminado')),
          );
        },
      ),
    );
  }

  String _generatePlanId() {
    final next = _plans.length + 1;
    return 'P${next.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppScaffold(
      title: 'Membresías',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showPlanDialog(),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanDialog(),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plans Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                final plan = _plans[index];
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.card_membership,
                              color: colorScheme.primary,
                              size: 32,
                            ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _showPlanDialog(plan: plan);
                                    break;
                                  case 'delete':
                                    _confirmDelete(plan);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete),
                                      SizedBox(width: 8),
                                      Text('Eliminar'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          plan.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plan.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            MoneyFormatter.format(plan.price),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${plan.durationDays} días',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Características:',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...plan.features.take(3).map((feature) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            feature,
                                            style: theme.textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              if (plan.features.length > 3)
                                Text(
                                  '+${plan.features.length - 3} más',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
