import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';

// Asymmetric Duel Screen - Create or manage bets against others
class AsymmetricBetScreen extends ConsumerWidget {
  const AsymmetricBetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paris asymétriques'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mes paris', icon: Icon(Icons.bet, size: 20)),
              Tab(text: 'Créer un pari', icon: Icon(Icons.add, size: 20)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMyBetsTab(),
            _buildCreateBetTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBetsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info Card
        Card(
          color: Colors.orange[50],
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pariez qu\'un ami échouera à son stake. S\'il réussit, il gagne votre mise avec bonus !',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Active Bets
        _buildBetCard(
          friendName: 'Thomas D.',
          stakeTitle: 'Courir 5km chaque jour',
          betAmount: 50.0,
          odds: 2.5,
          potentialLoss: 125.0,
          status: 'active',
          progress: 0.6,
          daysLeft: 5,
        ),
        _buildBetCard(
          friendName: 'Marie L.',
          stakeTitle: 'Ne pas manger de sucre',
          betAmount: 30.0,
          odds: 3.0,
          potentialLoss: 90.0,
          status: 'pending',
        ),
      ],
    );
  }

  Widget _buildBetCard({
    required String friendName,
    required String stakeTitle,
    required double betAmount,
    required double odds,
    required double potentialLoss,
    required String status,
    double? progress,
    int? daysLeft,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'active':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_bottom;
        statusText = 'En cours';
        break;
      case 'pending':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        statusText = 'En attente';
        break;
      case 'won':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Gagné';
        break;
      case 'lost':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Perdu';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Inconnu';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pari contre $friendName',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stakeTitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Progress (if active)
            if (progress != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.7 ? Colors.red : Colors.green,
                ),
              ),
              if (daysLeft != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reste $daysLeft jours',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],

            // Bet Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.euro, color: Colors.blue, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      '${betAmount.toStringAsFixed(0)}€',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Votre mise',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.orange, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      '${odds}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Cote',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      '${potentialLoss.toStringAsFixed(0)}€',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      'Perte max',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateBetTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Instructions
        Card(
          color: Colors.blue[50],
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Comment ça marche ?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('1. Choisissez un ami qui a un stake actif'),
                SizedBox(height: 4),
                Text('2. Pariez qu\'il va échouer'),
                SizedBox(height: 4),
                Text('3. S\'il échoue, vous gardez votre mise'),
                SizedBox(height: 4),
                Text('4. S\'il réussit, il gagne votre mise × la cote !'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Stakes disponibles',
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 12),

        // Available Stakes to Bet Against
        _buildAvailableStakeCard(
          context,
          friendName: 'Thomas D.',
          stakeTitle: 'Courir 5km tous les jours',
          progress: 0.4,
          daysLeft: 10,
          difficulty: 'Difficile',
          suggestedOdds: 2.5,
        ),
        _buildAvailableStakeCard(
          context,
          friendName: 'Marie L.',
          stakeTitle: 'Méditer 20min quotidiennement',
          progress: 0.8,
          daysLeft: 5,
          difficulty: 'Facile',
          suggestedOdds: 4.0,
        ),
      ],
    );
  }

  Widget _buildAvailableStakeCard(
    BuildContext context, {
    required String friendName,
    required String stakeTitle,
    required double progress,
    required int daysLeft,
    required String difficulty,
    required double suggestedOdds,
  }) {
    Color difficultyColor;
    switch (difficulty) {
      case 'Facile':
        difficultyColor = Colors.green;
        break;
      case 'Moyen':
        difficultyColor = Colors.orange;
        break;
      case 'Difficile':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(friendName.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friendName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        stakeTitle,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      color: difficultyColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progression: ${(progress * 100).toInt()}%',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: progress),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Cote: ${suggestedOdds}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '$daysLeft jours',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () => _createBet(context, friendName, stakeTitle, suggestedOdds),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Parier contre'),
            ),
          ],
        ),
      ),
    );
  }

  void _createBet(BuildContext context, String friendName, String stakeTitle, double odds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Parier contre $friendName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stake: $stakeTitle'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Montant du pari (€)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.euro),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('Cote: ${odds}x'),
                  const SizedBox(height: 4),
                  Text(
                    'Si ${friendName.split(' ')[0]} réussit, vous perdez votre mise × $odds',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pari créé ! En attente d\'acceptation.')),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
