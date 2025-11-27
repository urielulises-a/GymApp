import 'package:flutter/material.dart';
import '../../core/models/plan.dart';
import '../../core/services/plans_service.dart';
import '../../core/services/http_service.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/app_scaffold.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final _plansService = PlansService();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _featuresController = TextEditingController();

  List<Plan> _plans = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);

    try {
      final response = await _plansService.getPlans(
        page: 1,
        limit: 100,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (mounted) {
        setState(() {
          _plans = response.data ?? [];
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Error al cargar planes: ${e.message}');
      }
    }
  }

  Future<void> _createOrUpdatePlan({Plan? existingPlan}) async {
    try {
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final duration = int.tryParse(_durationController.text) ?? 30;
      final features = _featuresController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (existingPlan == null) {
        await _plansService.createPlan(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          durationDays: duration,
          features: features,
        );
        _showSuccess('Plan creado exitosamente');
      } else {
        await _plansService.updatePlan(
          existingPlan.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          durationDays: duration,
          features: features,
        );
        _showSuccess('Plan actualizado exitosamente');
      }

      if (mounted) {
        Navigator.of(context).pop();
        _loadPlans();
      }
    } on ApiException catch (e) {
      _showError(e.message);
    }
  }

  Future<void> _deletePlan(Plan plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar el plan "${plan.name}"?'),
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
      await _plansService.deletePlan(plan.id);
      _showSuccess('Plan eliminado');
      _loadPlans();
    } on ApiException catch (e) {
      _showError(e.message);
    }
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
      _priceController.text = plan.price.toString();
      _durationController.text = plan.durationDays.toString();
      _featuresController.text = plan.features.join(', ');
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plan == null ? 'Nuevo Plan' : 'Editar Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración (días)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _featuresController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Características (separadas por coma)',
                  border: OutlineInputBorder(),
                  hintText: 'Gym, Clases, Spa',
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
            onPressed: () => _createOrUpdatePlan(existingPlan: plan),
            child: const Text('Guardar'),
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
    return AppScaffold(
      title: 'Planes',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar plan',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              onSubmitted: (_) => _loadPlans(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _plans.isEmpty
                    ? const Center(child: Text('No hay planes'))
                    : ListView.builder(
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                child: Text(
                                  plan.name.isNotEmpty ? plan.name[0].toUpperCase() : 'P',
                                ),
                              ),
                              title: Text(
                                plan.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${MoneyFormatter.format(plan.price)} - ${plan.durationDays} días',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Descripción: ${plan.description}',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text('Características:'),
                                      ...plan.features.map(
                                        (f) => Text(
                                          '  • $f',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          if (constraints.maxWidth > 300) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () =>
                                                      _showPlanDialog(plan: plan),
                                                  icon: const Icon(Icons.edit),
                                                  label: const Text('Editar'),
                                                ),
                                                const SizedBox(width: 8),
                                                TextButton.icon(
                                                  onPressed: () => _deletePlan(plan),
                                                  icon: const Icon(Icons.delete),
                                                  label: const Text('Eliminar'),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                FilledButton.icon(
                                                  onPressed: () =>
                                                      _showPlanDialog(plan: plan),
                                                  icon: const Icon(Icons.edit),
                                                  label: const Text('Editar'),
                                                ),
                                                const SizedBox(height: 8),
                                                OutlinedButton.icon(
                                                  onPressed: () => _deletePlan(plan),
                                                  icon: const Icon(Icons.delete),
                                                  label: const Text('Eliminar'),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
