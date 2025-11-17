import 'package:flutter/material.dart';
import '../../../shared/models/challenge_model.dart';
import '../../../core/theme/app_constants.dart';

// Rematch System - Allows users to quickly create a rematch after completing a challenge
class RematchWidget extends StatelessWidget {
  final ChallengeModel completedChallenge;
  final VoidCallback onRematchPressed;

  const RematchWidget({
    super.key,
    required this.completedChallenge,
    required this.onRematchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.refresh, color: Colors.orange, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Revanche ?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lancez un nouveau challenge avec les mêmes participants',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRematchPressed,
              icon: const Icon(Icons.sports_mma),
              label: const Text('Lancer la revanche'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Rematch Dialog - Shows rematch options
class RematchDialog extends StatefulWidget {
  final ChallengeModel previousChallenge;

  const RematchDialog({super.key, required this.previousChallenge});

  @override
  State<RematchDialog> createState() => _RematchDialogState();
}

class _RematchDialogState extends State<RematchDialog> {
  bool _sameSettings = true;
  double? _newEntryFee;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.refresh, color: Colors.orange),
          SizedBox(width: 8),
          Text('Créer une revanche'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Défiez à nouveau les participants du challenge :',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '"${widget.previousChallenge.title}"',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // Same Settings Toggle
            CheckboxListTile(
              value: _sameSettings,
              onChanged: (value) => setState(() => _sameSettings = value!),
              title: const Text('Garder les mêmes paramètres'),
              subtitle: const Text('Type, durée, mode de preuve identiques'),
              contentPadding: EdgeInsets.zero,
            ),

            if (!_sameSettings) ...[
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nouvelle mise (€)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() => _newEntryFee = double.tryParse(value));
                },
              ),
            ],

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tous les participants recevront une invitation',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Create rematch challenge
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Revanche créée ! Invitations envoyées.'),
              ),
            );
          },
          child: const Text('Créer la revanche'),
        ),
      ],
    );
  }
}
