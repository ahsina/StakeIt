import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/stake_model.dart';
import '../../../core/router/app_router.dart';
import '../data/providers/stake_provider.dart';

class CreateStakeScreen extends ConsumerStatefulWidget {
  const CreateStakeScreen({super.key});

  @override
  ConsumerState<CreateStakeScreen> createState() => _CreateStakeScreenState();
}

class _CreateStakeScreenState extends ConsumerState<CreateStakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _requiredCountController = TextEditingController();

  StakeCategory _selectedCategory = StakeCategory.fitness;
  ProofMode _selectedProofMode = ProofMode.manual;
  FailureMode _selectedFailureMode = FailureMode.allOrNothing;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _requiredCountController.dispose();
    super.dispose();
  }

  Future<void> _selectEndDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Date de fin',
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 23, minute: 59),
        helpText: 'Heure de fin',
      );

      if (time != null) {
        setState(() {
          _endDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _handleCreateStake() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de fin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = CreateStakeRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        amountEUR: double.parse(_amountController.text),
        endDate: _endDate!,
        requiredCount: int.parse(_requiredCountController.text),
        proofMode: _selectedProofMode,
        failureMode: _selectedFailureMode,
      );

      final stake = await ref.read(stakesProvider.notifier).createStake(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stake créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to stake detail
      context.go('${AppRoutes.home}/stakes/${stake.id}');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Stake'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                hintText: 'Ex: Aller à la salle 3 fois cette semaine',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un titre';
                }
                if (value.length < 3) {
                  return 'Le titre doit contenir au moins 3 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Détails supplémentaires...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<StakeCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Catégorie *',
                prefixIcon: Icon(Icons.category),
              ),
              items: StakeCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Montant (EUR) *',
                hintText: '20.00',
                prefixIcon: Icon(Icons.euro),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un montant';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Montant invalide';
                }
                if (amount < 5.0 || amount > 500.0) {
                  return 'Le montant doit être entre 5€ et 500€';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // End Date
            InkWell(
              onTap: _selectEndDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de fin *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _endDate == null
                      ? 'Sélectionnez la date et heure de fin'
                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year} à ${_endDate!.hour}:${_endDate!.minute.toString().padLeft(2, '0')}',
                  style: _endDate == null
                      ? TextStyle(color: Colors.grey[600])
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Required Count
            TextFormField(
              controller: _requiredCountController,
              decoration: const InputDecoration(
                labelText: 'Nombre de fois requis *',
                hintText: '3',
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nombre';
                }
                final count = int.tryParse(value);
                if (count == null || count < 1) {
                  return 'Le nombre doit être au moins 1';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Proof Mode
            DropdownButtonFormField<ProofMode>(
              value: _selectedProofMode,
              decoration: const InputDecoration(
                labelText: 'Mode de preuve *',
                prefixIcon: Icon(Icons.verified),
              ),
              items: const [
                DropdownMenuItem(
                  value: ProofMode.manual,
                  child: Text('Manuel (validation manuelle)'),
                ),
                DropdownMenuItem(
                  value: ProofMode.gps,
                  child: Text('GPS (localisation)'),
                ),
                DropdownMenuItem(
                  value: ProofMode.photo,
                  child: Text('Photo (image)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedProofMode = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Failure Mode
            DropdownButtonFormField<FailureMode>(
              value: _selectedFailureMode,
              decoration: const InputDecoration(
                labelText: 'Mode d\'échec *',
                prefixIcon: Icon(Icons.warning),
              ),
              items: const [
                DropdownMenuItem(
                  value: FailureMode.allOrNothing,
                  child: Text('Tout ou rien'),
                ),
                DropdownMenuItem(
                  value: FailureMode.proRata,
                  child: Text('Prorata (proportionnel)'),
                ),
                DropdownMenuItem(
                  value: FailureMode.progressive,
                  child: Text('Progressif'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFailureMode = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informations importantes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Le montant sera pré-autorisé sur votre carte\n'
                      '• Il sera capturé uniquement en cas d\'échec\n'
                      '• Commission de 10% sur les échecs\n'
                      '• Vous pouvez annuler dans les 2h après création',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleCreateStake,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Créer le Stake'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(StakeCategory category) {
    switch (category) {
      case StakeCategory.fitness:
        return 'Fitness';
      case StakeCategory.education:
        return 'Éducation';
      case StakeCategory.productivity:
        return 'Productivité';
      case StakeCategory.finance:
        return 'Finance';
      case StakeCategory.personalDevelopment:
        return 'Développement Personnel';
      case StakeCategory.family:
        return 'Famille';
      case StakeCategory.creativity:
        return 'Créativité';
      case StakeCategory.home:
        return 'Maison';
      case StakeCategory.digitalDetox:
        return 'Détox Numérique';
    }
  }
}
