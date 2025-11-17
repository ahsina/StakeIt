import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';

// Team Battles - 2 teams compete against each other
class TeamBattlesScreen extends ConsumerStatefulWidget {
  const TeamBattlesScreen({super.key});

  @override
  ConsumerState<TeamBattlesScreen> createState() => _TeamBattlesScreenState();
}

class _TeamBattlesScreenState extends ConsumerState<TeamBattlesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batailles d\'équipes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Actives', icon: Icon(Icons.groups, size: 20)),
            Tab(text: 'Créer', icon: Icon(Icons.add_circle, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveBattlesTab(),
          _buildCreateBattleTab(context),
        ],
      ),
    );
  }

  Widget _buildActiveBattlesTab() {
    // Mock data
    final battles = [
      {
        'id': 1,
        'title': 'Marathon Team Challenge',
        'team1': 'Les Rapides',
        'team2': 'Les Endurants',
        'team1Score': 850,
        'team2Score': 920,
        'team1Members': 5,
        'team2Members': 5,
        'pot': 500.0,
        'daysLeft': 3,
        'myTeam': 1,
      },
      {
        'id': 2,
        'title': 'Fitness Warriors',
        'team1': 'Team Alpha',
        'team2': 'Team Beta',
        'team1Score': 1200,
        'team2Score': 1150,
        'team1Members': 4,
        'team2Members': 6,
        'pot': 360.0,
        'daysLeft': 7,
        'myTeam': 2,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: battles.length,
      itemBuilder: (context, index) {
        final battle = battles[index];
        return _buildBattleCard(context, battle);
      },
    );
  }

  Widget _buildBattleCard(BuildContext context, Map<String, dynamic> battle) {
    final team1Score = battle['team1Score'] as int;
    final team2Score = battle['team2Score'] as int;
    final totalScore = team1Score + team2Score;
    final team1Progress = team1Score / totalScore;
    final team2Progress = team2Score / totalScore;
    final isWinning = (battle['myTeam'] == 1 && team1Score > team2Score) ||
        (battle['myTeam'] == 2 && team2Score > team1Score);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showBattleDetail(context, battle),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      battle['title'] as String,
                      style: AppTextStyles.headingSmall,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isWinning ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWinning ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: isWinning ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isWinning ? 'Gagnant' : 'Perdant',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isWinning ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Teams Display
              Row(
                children: [
                  // Team 1
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.shield, color: Colors.blue, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                battle['team1'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '${battle['team1Members']} membres',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$team1Score pts',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // VS
                  Column(
                    children: [
                      const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${battle['pot']}€',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Team 2
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.shield, color: Colors.red, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                battle['team2'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '${battle['team2Members']} membres',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$team2Score pts',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    Expanded(
                      flex: (team1Progress * 100).toInt(),
                      child: Container(
                        height: 20,
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      flex: (team2Progress * 100).toInt(),
                      child: Container(
                        height: 20,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Reste ${battle['daysLeft']} jours',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showBattleDetail(context, battle),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Détails'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
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

  Widget _buildCreateBattleTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Card(
            color: Colors.blue[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Créer une bataille d\'équipes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('• 2 équipes s\'affrontent'),
                  SizedBox(height: 4),
                  Text('• Score cumulé par équipe'),
                  SizedBox(height: 4),
                  Text('• L\'équipe gagnante partage le pot'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Form
          TextField(
            decoration: const InputDecoration(
              labelText: 'Titre de la bataille',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            decoration: const InputDecoration(
              labelText: 'Objectif',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nom Équipe 1',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nom Équipe 2',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Mise par membre (€)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.euro),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Durée (jours)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => _createBattle(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Créer la bataille'),
          ),
        ],
      ),
    );
  }

  void _showBattleDetail(BuildContext context, Map<String, dynamic> battle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(battle['title'] as String),
          ),
          body: const Center(
            child: Text('Détails de la bataille d\'équipes'),
          ),
        ),
      ),
    );
  }

  void _createBattle(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bataille créée avec succès !')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
