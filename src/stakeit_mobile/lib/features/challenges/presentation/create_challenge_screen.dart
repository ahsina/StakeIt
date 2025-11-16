import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/challenge_model.dart';
import '../../../shared/models/stake_model.dart';
import '../../../core/router/app_router.dart';
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
        const SnackBar(
          content: Text('Veuillez sélectionner les dates de début et de fin'),
          backgroundColor: Colors.red,
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
        const SnackBar(
          content: Text('Challenge créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      context.go('${AppRoutes.home}/challenges/${challenge.id}');
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                hintText: 'Ex: Course de 10km en 1 mois',
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
                hintText: 'Détails sur le challenge...',
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
            TextFormField(
              controller: _entryFeeController,
              decoration: const InputDecoration(
                labelText: 'Frais d\'entrée (EUR) *',
                hintText: '10.00',
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

            // Max Participants
            TextFormField(
              controller: _maxParticipantsController,
              decoration: const InputDecoration(
                labelText: 'Nombre maximum de participants *',
                hintText: '10',
                prefixIcon: Icon(Icons.people),
              ),
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
            const SizedBox(height: 16),

            // Target Count
            TextFormField(
              controller: _targetCountController,
              decoration: const InputDecoration(
                labelText: 'Objectif à atteindre *',
                hintText: '10',
                prefixIcon: Icon(Icons.flag),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un objectif';
                }
                final count = int.tryParse(value);
                if (count == null || count < 1) {
                  return 'L\'objectif doit être au moins 1';
                }
                return null;
              },
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
                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} à ${_startDate!.hour}:${_startDate!.minute.toString().padLeft(2, '0')}',
                  style: _startDate == null
                      ? TextStyle(color: Colors.grey[600])
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

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
                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year} à ${_endDate!.hour}:${_endDate!.minute.toString().padLeft(2, '0')}',
                  style:
                      _endDate == null ? TextStyle(color: Colors.grey[600]) : null,
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
                          'À propos des challenges',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Vous serez automatiquement inscrit comme créateur\n'
                      '• Les frais d\'entrée sont prélevés à tous les participants\n'
                      '• La cagnotte totale est distribuée aux gagnants (90%)\n'
                      '• Commission de 10% sur la cagnotte totale\n'
                      '• Le challenge peut être annulé avant le début',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleCreateChallenge,
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
                  : const Text('Créer le Challenge'),
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
