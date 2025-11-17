import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';

// Leagues/Ladders System - Competitive rankings with seasons
class LeaguesScreen extends ConsumerStatefulWidget {
  const LeaguesScreen({super.key});

  @override
  ConsumerState<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends ConsumerState<LeaguesScreen> {
  String _selectedLeague = 'bronze';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ligues & Classements'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Season Info
          _buildSeasonCard(),
          const SizedBox(height: 24),

          // League Selector
          Text(
            'Sélectionner une ligue',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 12),
          _buildLeagueSelector(),

          const SizedBox(height: 24),

          // Current League Leaderboard
          Text(
            'Classement ${_getLeagueName(_selectedLeague)}',
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 12),
          ..._buildLeaderboard(_selectedLeague),

          const SizedBox(height: 24),

          // Promotion/Relegation Info
          _buildPromotionInfo(),
        ],
      ),
    );
  }

  Widget _buildSeasonCard() {
    return Card(
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Saison 2025-Q4',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '15 jours restants',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Début: 01/10/2025'),
                const Text('Fin: 31/12/2025'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueSelector() {
    final leagues = [
      {'id': 'bronze', 'name': 'Bronze', 'color': Colors.brown, 'icon': '🥉'},
      {'id': 'silver', 'name': 'Argent', 'color': Colors.grey, 'icon': '🥈'},
      {'id': 'gold', 'name': 'Or', 'color': Colors.amber, 'icon': '🥇'},
      {'id': 'platinum', 'name': 'Platine', 'color': Colors.cyan, 'icon': '💎'},
      {'id': 'diamond', 'name': 'Diamant', 'color': Colors.blue, 'icon': '💠'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: leagues.map((league) {
          final isSelected = _selectedLeague == league['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedLeague = league['id'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? (league['color'] as Color).withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (league['color'] as Color)
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    league['icon'] as String,
                    style: TextStyle(fontSize: isSelected ? 32 : 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    league['name'] as String,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? league['color'] as Color : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildLeaderboard(String leagueId) {
    // Mock leaderboard data
    final players = List.generate(10, (index) {
      return {
        'rank': index + 1,
        'name': 'Joueur ${index + 1}',
        'points': 1000 - (index * 50),
        'change': index % 3 == 0 ? 'up' : (index % 3 == 1 ? 'down' : 'same'),
      };
    });

    return players.map((player) {
      final isTopThree = (player['rank'] as int) <= 3;
      final isCurrentUser = (player['rank'] as int) == 5;

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: isCurrentUser ? Colors.blue[50] : null,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTopThree ? Colors.amber.withOpacity(0.2) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#${player['rank']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isTopThree ? Colors.amber[800] : Colors.black,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                player['name'] as String,
                style: TextStyle(
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'VOUS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Row(
            children: [
              Icon(
                player['change'] == 'up'
                    ? Icons.arrow_upward
                    : player['change'] == 'down'
                        ? Icons.arrow_downward
                        : Icons.remove,
                size: 14,
                color: player['change'] == 'up'
                    ? Colors.green
                    : player['change'] == 'down'
                        ? Colors.red
                        : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text('${player['points']} points'),
            ],
          ),
          trailing: isTopThree
              ? Text(
                  player['rank'] == 1
                      ? '🥇'
                      : player['rank'] == 2
                          ? '🥈'
                          : '🥉',
                  style: const TextStyle(fontSize: 24),
                )
              : null,
        ),
      );
    }).toList();
  }

  Widget _buildPromotionInfo() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Règles de promotion',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPromotionRule(
              icon: Icons.arrow_upward,
              color: Colors.green,
              text: 'Top 3 : Promotion à la ligue supérieure',
            ),
            _buildPromotionRule(
              icon: Icons.arrow_downward,
              color: Colors.red,
              text: 'Bottom 3 : Relégation à la ligue inférieure',
            ),
            _buildPromotionRule(
              icon: Icons.emoji_events,
              color: Colors.amber,
              text: '1er place : Bonus 100€',
            ),
            const SizedBox(height: 12),
            const Text(
              'Nouvelle saison le 1er janvier 2026',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionRule({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  String _getLeagueName(String id) {
    switch (id) {
      case 'bronze':
        return 'Bronze 🥉';
      case 'silver':
        return 'Argent 🥈';
      case 'gold':
        return 'Or 🥇';
      case 'platinum':
        return 'Platine 💎';
      case 'diamond':
        return 'Diamant 💠';
      default:
        return 'Bronze 🥉';
    }
  }
}
