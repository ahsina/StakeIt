import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/stake_model.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/info_card.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/utils/error_mapper.dart';
import '../../../shared/utils/date_formatter.dart';
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
  StakeFrequency _selectedFrequency = StakeFrequency.custom;
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
        frequency: _selectedFrequency,
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
          content: Text(ErrorMapper.mapStakeError(e)),
          backgroundColor: AppColors.error,
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
            CustomTextField(
              label: 'Titre',
              hint: 'Ex: Aller à la salle 3 fois cette semaine',
              controller: _titleController,
              prefixIcon: const Icon(Icons.title),
              validator: (value) => Validators.validateMinLength(value, 3, fieldName: 'Le titre'),
            ),
            const SizedBox(height: 16),

            // Description
            CustomTextField(
              label: 'Description (optionnel)',
              hint: 'Détails supplémentaires...',
              controller: _descriptionController,
              prefixIcon: const Icon(Icons.description),
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
            CurrencyTextField(
              label: 'Montant (EUR)',
              hint: '20.00',
              controller: _amountController,
              validator: (value) => Validators.validateAmount(value, min: 5.0, max: 500.0),
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
                      : DateFormatter.formatLongDateTime(_endDate!),
                  style: _endDate == null
                      ? TextStyle(color: AppColors.textSecondary)
                      : AppTextStyles.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Frequency
            DropdownButtonFormField<StakeFrequency>(
              value: _selectedFrequency,
              decoration: const InputDecoration(
                labelText: 'Fréquence *',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [
                DropdownMenuItem(
                  value: StakeFrequency.daily,
                  child: Text('Quotidien'),
                ),
                DropdownMenuItem(
                  value: StakeFrequency.weekly,
                  child: Text('Hebdomadaire'),
                ),
                DropdownMenuItem(
                  value: StakeFrequency.custom,
                  child: Text('Personnalisé'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFrequency = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Required Count
            CustomTextField(
              label: 'Nombre de fois requis',
              hint: '3',
              controller: _requiredCountController,
              prefixIcon: const Icon(Icons.numbers),
              keyboardType: TextInputType.number,
              validator: Validators.validatePositiveNumber,
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
            WarningCard(
              message: '• Le montant sera pré-autorisé sur votre carte\n'
                  '• Il sera capturé uniquement en cas d\'échec\n'
                  '• Commission de 10% sur les échecs\n'
                  '• Vous pouvez annuler dans les 2h après création',
              icon: Icons.info_outline,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),

            // Create Button
            CustomButton(
              text: 'Créer le Stake',
              onPressed: _handleCreateStake,
              isLoading: _isLoading,
              type: ButtonType.primary,
              size: ButtonSize.large,
              isFullWidth: true,
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
