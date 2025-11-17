import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/challenge_model.dart';
import '../../../core/theme/app_constants.dart';

// Spectator Mode allows friends to watch challenges and optionally place mini-bets
class SpectatorModeScreen extends ConsumerStatefulWidget {
  final int challengeId;

  const SpectatorModeScreen({super.key, required this.challengeId});

  @override
  ConsumerState<SpectatorModeScreen> createState() => _SpectatorModeScreenState();
}

class _SpectatorModeScreenState extends ConsumerState<SpectatorModeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Spectateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareChallenge,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Live', icon: Icon(Icons.live_tv, size: 20)),
            Tab(text: 'Classement', icon: Icon(Icons.leaderboard, size: 20)),
            Tab(text: 'Paris', icon: Icon(Icons.monetization_on, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveTab(),
          _buildLeaderboardTab(),
          _buildBetsTab(),
        ],
      ),
    );
  }

  Widget _buildLiveTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: Colors.white, size: 12),
              SizedBox(width: 6),
              Text(
                'EN DIRECT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Challenge Info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Challenge 100km Running',
                  style: AppTextStyles.headingMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '5 participants • Pot: 250€',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const LinearProgressIndicator(value: 0.65),
                const SizedBox(height: 8),
                Text(
                  'Temps restant: 2j 14h 30m',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'Activité en direct',
          style: AppTextStyles.headingSmall,
        ),
        const SizedBox(height: 12),

        // Live Feed
        ..._buildLiveFeed(),
      ],
    );
  }

  List<Widget> _buildLiveFeed() {
    final activities = [
      {'user': 'Marie L.', 'action': 'a soumis une preuve', 'time': '2 min', 'icon': Icons.check_circle, 'color': Colors.green},
      {'user': 'Thomas D.', 'action': 'a pris la 1ère place', 'time': '15 min', 'icon': Icons.emoji_events, 'color': Colors.amber},
      {'user': 'Sophie M.', 'action': 'a envoyé un message', 'time': '23 min', 'icon': Icons.chat_bubble, 'color': Colors.blue},
      {'user': 'Lucas P.', 'action': 'a soumis une preuve', 'time': '1h', 'icon': Icons.check_circle, 'color': Colors.green},
      {'user': 'Emma R.', 'action': 'a rejoint les spectateurs', 'time': '2h', 'icon': Icons.visibility, 'color': Colors.purple},
    ];

    return activities.map((activity) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: (activity['color'] as Color).withOpacity(0.2),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 20,
            ),
          ),
          title: RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium,
              children: [
                TextSpan(
                  text: activity['user'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ${activity['action']}'),
              ],
            ),
          ),
          trailing: Text(
            'Il y a ${activity['time']}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLeaderboardTab() {
    final participants = [
      {'rank': 1, 'name': 'Marie L.', 'score': 85, 'progress': 0.85},
      {'rank': 2, 'name': 'Thomas D.', 'score': 72, 'progress': 0.72},
      {'rank': 3, 'name': 'Sophie M.', 'score': 68, 'progress': 0.68},
      {'rank': 4, 'name': 'Lucas P.', 'score': 45, 'progress': 0.45},
      {'rank': 5, 'name': 'Emma R.', 'score': 30, 'progress': 0.30},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(participant['rank'] as int).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '#${participant['rank']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(participant['rank'] as int),
                  ),
                ),
              ),
            ),
            title: Text(participant['name'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: participant['progress'] as double,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getRankColor(participant['rank'] as int),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${participant['score']} / 100'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBetsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info Card
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pariez sur le gagnant et multipliez vos gains !',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'Parier sur le gagnant',
          style: AppTextStyles.headingSmall,
        ),
        const SizedBox(height: 12),

        // Bet Options
        ..._buildBetOptions(),

        const SizedBox(height: 24),
        Text(
          'Mes paris',
          style: AppTextStyles.headingSmall,
        ),
        const SizedBox(height: 12),

        // My Bets
        _buildMyBets(),
      ],
    );
  }

  List<Widget> _buildBetOptions() {
    final options = [
      {'name': 'Marie L.', 'odds': '2.5x', 'rank': 1, 'chance': 'Favorite'},
      {'name': 'Thomas D.', 'odds': '3.2x', 'rank': 2, 'chance': 'Probable'},
      {'name': 'Sophie M.', 'odds': '4.0x', 'rank': 3, 'chance': 'Possible'},
      {'name': 'Lucas P.', 'odds': '8.5x', 'rank': 4, 'chance': 'Outsider'},
      {'name': 'Emma R.', 'odds': '15x', 'rank': 5, 'chance': 'Longshot'},
    ];

    return options.map((option) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getRankColor(option['rank'] as int).withOpacity(0.2),
            child: Text(
              '#${option['rank']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getRankColor(option['rank'] as int),
              ),
            ),
          ),
          title: Text(option['name'] as String),
          subtitle: Text(option['chance'] as String),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                option['odds'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              ElevatedButton(
                onPressed: () => _placeBet(option['name'] as String),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: const Text('Parier', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMyBets() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.monetization_on, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Aucun pari actif'),
            const SizedBox(height: 8),
            Text(
              'Pariez sur un participant pour commencer',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }

  void _shareChallenge() {
    // TODO: Share challenge
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lien de partage copié !')),
    );
  }

  void _placeBet(String participantName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Parier sur $participantName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Montant (€)',
                prefixIcon: Icon(Icons.euro),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Gain potentiel: 25€\nCommission: 20%',
                textAlign: TextAlign.center,
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
                SnackBar(content: Text('Pari placé sur $participantName !')),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
