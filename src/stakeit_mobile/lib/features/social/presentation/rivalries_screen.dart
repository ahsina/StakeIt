import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';

class Rivalry {
  final int id;
  final String rivalName;
  final int myWins;
  final int rivalWins;
  final int totalChallenges;
  final double totalStaked;
  final String lastResult; // 'win', 'loss', 'pending'
  final DateTime? lastChallengeDate;

  Rivalry({
    required this.id,
    required this.rivalName,
    required this.myWins,
    required this.rivalWins,
    required this.totalChallenges,
    required this.totalStaked,
    required this.lastResult,
    this.lastChallengeDate,
  });

  double get winRate => totalChallenges > 0 ? myWins / totalChallenges : 0;
  String get record => '$myWins-$rivalWins';
}

class RivalriesScreen extends ConsumerWidget {
  const RivalriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data
    final rivalries = [
      Rivalry(
        id: 1,
        rivalName: 'Thomas D.',
        myWins: 8,
        rivalWins: 5,
        totalChallenges: 13,
        totalStaked: 650,
        lastResult: 'win',
        lastChallengeDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Rivalry(
        id: 2,
        rivalName: 'Marie L.',
        myWins: 4,
        rivalWins: 7,
        totalChallenges: 11,
        totalStaked: 550,
        lastResult: 'loss',
        lastChallengeDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Rivalry(
        id: 3,
        rivalName: 'Lucas P.',
        myWins: 6,
        rivalWins: 6,
        totalChallenges: 12,
        totalStaked: 480,
        lastResult: 'pending',
        lastChallengeDate: DateTime.now(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Rivalités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showRivalriesInfo(context),
          ),
        ],
      ),
      body: rivalries.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rivalries.length,
              itemBuilder: (context, index) {
                return _buildRivalryCard(context, rivalries[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_mma, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucune rivalité',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Affrontez vos amis dans des challenges pour créer des rivalités !',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRivalryCard(BuildContext context, Rivalry rivalry) {
    final winRateColor = rivalry.winRate >= 0.6
        ? Colors.green
        : rivalry.winRate >= 0.4
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showRivalryDetail(context, rivalry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      rivalry.rivalName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rivalry.rivalName,
                          style: AppTextStyles.headingSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${rivalry.totalChallenges} challenges',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildLastResultBadge(rivalry.lastResult),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    'Record',
                    rivalry.record,
                    Icons.emoji_events,
                    winRateColor,
                  ),
                  _buildStatColumn(
                    'Taux victoire',
                    '${(rivalry.winRate * 100).toInt()}%',
                    Icons.trending_up,
                    winRateColor,
                  ),
                  _buildStatColumn(
                    'Mise totale',
                    '${rivalry.totalStaked.toInt()}€',
                    Icons.euro,
                    Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewHistory(context, rivalry),
                      icon: const Icon(Icons.history),
                      label: const Text('Historique'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _challengeRival(context, rivalry),
                      icon: const Icon(Icons.sports_mma),
                      label: const Text('Défier'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastResultBadge(String result) {
    Color color;
    IconData icon;
    String label;

    switch (result) {
      case 'win':
        color = Colors.green;
        icon = Icons.arrow_upward;
        label = 'V';
        break;
      case 'loss':
        color = Colors.red;
        icon = Icons.arrow_downward;
        label = 'D';
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        label = 'En cours';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = '?';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showRivalryDetail(BuildContext context, Rivalry rivalry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Title
              Text(
                'Rivalité avec ${rivalry.rivalName}',
                style: AppTextStyles.headingLarge,
              ),
              const SizedBox(height: 24),

              // Win/Loss Chart
              _buildWinLossChart(rivalry),

              const SizedBox(height: 24),

              // Recent Matches
              Text(
                'Derniers affrontements',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 12),
              _buildRecentMatches(rivalry),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinLossChart(Rivalry rivalry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: rivalry.myWins,
                child: Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      '${rivalry.myWins}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: rivalry.rivalWins,
                child: Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      '${rivalry.rivalWins}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Vous', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(rivalry.rivalName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMatches(Rivalry rivalry) {
    // Mock recent matches
    final matches = List.generate(5, (index) {
      return {
        'date': DateTime.now().subtract(Duration(days: index * 7)),
        'type': 'Challenge 10km',
        'result': index % 2 == 0 ? 'win' : 'loss',
        'amount': 50.0,
      };
    });

    return Column(
      children: matches.map((match) {
        final isWin = match['result'] == 'win';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isWin ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              child: Icon(
                isWin ? Icons.check : Icons.close,
                color: isWin ? Colors.green : Colors.red,
              ),
            ),
            title: Text(match['type'] as String),
            subtitle: Text(_formatDate(match['date'] as DateTime)),
            trailing: Text(
              '${isWin ? "+" : "-"}${match['amount']}€',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWin ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _viewHistory(BuildContext context, Rivalry rivalry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Historique vs ${rivalry.rivalName}'),
          ),
          body: const Center(
            child: Text('Liste complète des challenges'),
          ),
        ),
      ),
    );
  }

  void _challengeRival(BuildContext context, Rivalry rivalry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Challenge envoyé à ${rivalry.rivalName} !'),
      ),
    );
  }

  void _showRivalriesInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos des rivalités'),
        content: const Text(
          'Les rivalités se créent automatiquement quand vous affrontez régulièrement les mêmes personnes en challenge.\n\n'
          'Suivez vos statistiques et entretenez la compétition !',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Hier';
    if (diff < 7) return 'Il y a $diff jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}
