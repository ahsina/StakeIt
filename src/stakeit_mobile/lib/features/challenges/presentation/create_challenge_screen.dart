import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/challenge_model.dart';
import '../../../shared/models/stake_model.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/info_card.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/utils/error_mapper.dart';
import '../../../shared/utils/date_formatter.dart';
import '../data/providers/challenge_provider.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() =>
      _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _targetCountController = TextEditingController();

  StakeCategory _selectedCategory = StakeCategory.fitness;
  ChallengeType _selectedChallengeType = ChallengeType.highestScore;
  ProofMode _selectedProofMode = ProofMode.manual;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _allowSpectators = true;
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _entryFeeController.dispose();
    _maxParticipantsController.dispose();
    _targetCountController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Date de début',
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
        helpText: 'Heure de début',
      );

      if (time != null) {
        setState(() {
          _startDate = DateTime(
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

  Future<void> _selectEndDate() async {
    final now = _startDate ?? DateTime.now();
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

  Future<void> _handleCreateChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner les dates de début et de fin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = CreateChallengeRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        challengeType: _selectedChallengeType,
        maxParticipants: int.parse(_maxParticipantsController.text),
        entryFeeEUR: double.parse(_entryFeeController.text),
        startDate: _startDate!,
        endDate: _endDate!,
        targetCount: int.parse(_targetCountController.text),
        proofMode: _selectedProofMode,
        allowSpectators: _allowSpectators,
        isPublic: _isPublic,
      );

      final challenge =
          await ref.read(challengesProvider.notifier).createChallenge(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Challenge créé avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );

      context.go('${AppRoutes.home}/challenges/${challenge.id}');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorMapper.mapChallengeError(e)),
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
        title: const Text('Créer un Challenge'),
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
              hint: 'Ex: Course de 10km en 1 mois',
              controller: _titleController,
              prefixIcon: const Icon(Icons.title),
              validator: (value) => Validators.validateMinLength(value, 3, fieldName: 'Le titre'),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Description
            CustomTextField(
              label: 'Description (optionnel)',
              hint: 'Détails sur le challenge...',
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

            // Challenge Type
            DropdownButtonFormField<ChallengeType>(
              value: _selectedChallengeType,
              decoration: const InputDecoration(
                labelText: 'Type de challenge *',
                prefixIcon: Icon(Icons.emoji_events),
              ),
              items: const [
                DropdownMenuItem(
                  value: ChallengeType.firstToComplete,
                  child: Text('Premier à compléter'),
                ),
                DropdownMenuItem(
                  value: ChallengeType.highestScore,
                  child: Text('Score le plus élevé'),
                ),
                DropdownMenuItem(
                  value: ChallengeType.teamBased,
                  child: Text('En équipe'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedChallengeType = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Entry Fee
            CurrencyTextField(
              label: 'Frais d\'entrée (EUR)',
              hint: '10.00',
              controller: _entryFeeController,
              validator: (value) => Validators.validateAmount(value, min: 5.0, max: 500.0),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Max Participants
            CustomTextField(
              label: 'Nombre maximum de participants',
              hint: '10',
              controller: _maxParticipantsController,
              prefixIcon: const Icon(Icons.people),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nombre';
                }
                final count = int.tryParse(value);
                if (count == null || count < 2 || count > 100) {
                  return 'Le nombre doit être entre 2 et 100';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Target Count
            CustomTextField(
              label: 'Objectif à atteindre',
              hint: '10',
              controller: _targetCountController,
              prefixIcon: const Icon(Icons.flag),
              keyboardType: TextInputType.number,
              validator: Validators.validatePositiveNumber,
            ),
            const SizedBox(height: 16),

            // Start Date
            InkWell(
              onTap: _selectStartDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de début *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _startDate == null
                      ? 'Sélectionnez la date et heure de début'
                      : DateFormatter.formatLongDateTime(_startDate!),
                  style: _startDate == null
                      ? TextStyle(color: AppColors.textSecondary)
                      : AppTextStyles.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // End Date
            InkWell(
              onTap: _selectEndDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de fin *',
                  prefixIcon: Icon(Icons.event),
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
                  child: Text('Manuel'),
                ),
                DropdownMenuItem(
                  value: ProofMode.gps,
                  child: Text('GPS'),
                ),
                DropdownMenuItem(
                  value: ProofMode.photo,
                  child: Text('Photo'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedProofMode = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Options
            SwitchListTile(
              title: const Text('Autoriser les spectateurs'),
              subtitle: const Text(
                  'Les utilisateurs peuvent suivre le challenge sans participer'),
              value: _allowSpectators,
              onChanged: (value) {
                setState(() => _allowSpectators = value);
              },
            ),
            SwitchListTile(
              title: const Text('Challenge public'),
              subtitle: const Text(
                  'Visible dans la liste des challenges publics'),
              value: _isPublic,
              onChanged: (value) {
                setState(() => _isPublic = value);
              },
            ),
            const SizedBox(height: 24),

            // Info Card
            WarningCard(
              message: '• Vous serez automatiquement inscrit comme créateur\n'
                  '• Les frais d\'entrée sont prélevés à tous les participants\n'
                  '• La cagnotte totale est distribuée aux gagnants (90%)\n'
                  '• Commission de 10% sur la cagnotte totale\n'
                  '• Le challenge peut être annulé avant le début',
              icon: Icons.info_outline,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.paddingXXL),

            // Create Button
            CustomButton(
              text: 'Créer le Challenge',
              onPressed: _handleCreateChallenge,
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
