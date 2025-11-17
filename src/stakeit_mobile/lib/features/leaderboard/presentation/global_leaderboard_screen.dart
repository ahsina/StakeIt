import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/loading_indicator.dart';

// Leaderboard Types
enum LeaderboardType {
  global,
  monthly,
  local,
  friends,
  category,
}

enum LeaderboardCategory {
  all,
  fitness,
  learning,
  productivity,
  finance,
  personal,
  family,
  creativity,
  home,
  digital,
}

class LeaderboardEntry {
  final int rank;
  final UserModel user;
  final int totalXP;
  final int stakesCompleted;
  final int challengesWon;
  final double totalEarnings;
  final int currentStreak;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.user,
    required this.totalXP,
    required this.stakesCompleted,
    required this.challengesWon,
    required this.totalEarnings,
    required this.currentStreak,
    this.isCurrentUser = false,
  });
}

// Mock Provider for Leaderboard Data
final leaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, Map<String, dynamic>>(
  (ref, params) async {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    return List.generate(50, (index) {
      return LeaderboardEntry(
        rank: index + 1,
        user: UserModel(
          id: index + 1,
          email: 'user$index@example.com',
          firstName: 'User',
          lastName: '${index + 1}',
          level: 15 - (index ~/ 5),
          totalXP: 50000 - (index * 1000),
          currentStreak: 30 - index,
          createdAt: DateTime.now().subtract(Duration(days: 365 - index)),
          isPremium: index < 5,
        ),
        totalXP: 50000 - (index * 1000),
        stakesCompleted: 100 - index,
        challengesWon: 50 - (index ~/ 2),
        totalEarnings: (1000 - (index * 10)).toDouble(),
        currentStreak: 30 - index,
        isCurrentUser: index == 10,
      );
    });
  },
);

class GlobalLeaderboardScreen extends ConsumerStatefulWidget {
  const GlobalLeaderboardScreen({super.key});

  @override
  ConsumerState<GlobalLeaderboardScreen> createState() => _GlobalLeaderboardScreenState();
}

class _GlobalLeaderboardScreenState extends ConsumerState<GlobalLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardType _selectedType = LeaderboardType.global;
  LeaderboardCategory _selectedCategory = LeaderboardCategory.all;
  String _selectedCity = 'Luxembourg';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedType = LeaderboardType.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardData = ref.watch(leaderboardProvider({
      'type': _selectedType.toString(),
      'category': _selectedCategory.toString(),
      'city': _selectedCity,
    }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Global', icon: Icon(Icons.public, size: 20)),
            Tab(text: 'Mensuel', icon: Icon(Icons.calendar_month, size: 20)),
            Tab(text: 'Local', icon: Icon(Icons.location_on, size: 20)),
            Tab(text: 'Amis', icon: Icon(Icons.people, size: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(),

          // Leaderboard Content
          Expanded(
            child: leaderboardData.when(
              data: (entries) => _buildLeaderboard(entries),
              loading: () => const LoadingIndicator(message: 'Chargement du classement...'),
              error: (error, stack) => ErrorDisplay(
                message: 'Erreur lors du chargement',
                onRetry: () => ref.refresh(leaderboardProvider({
                  'type': _selectedType.toString(),
                  'category': _selectedCategory.toString(),
                  'city': _selectedCity,
                })),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Row(
        children: [
          // Category Filter
          Expanded(
            child: _buildFilterDropdown(
              value: _selectedCategory,
              items: LeaderboardCategory.values,
              onChanged: (value) => setState(() => _selectedCategory = value!),
              labelBuilder: (cat) => _getCategoryName(cat),
              icon: Icons.category,
            ),
          ),
          const SizedBox(width: 12),
          // City Filter (only for local leaderboard)
          if (_selectedType == LeaderboardType.local)
            Expanded(
              child: _buildCityDropdown(),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) labelBuilder,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      labelBuilder(item),
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    final cities = ['Luxembourg', 'Esch-sur-Alzette', 'Differdange', 'Dudelange'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: cities.map((city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Row(
                children: [
                  const Icon(Icons.location_city, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      city,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCity = value!),
        ),
      ),
    );
  }

  Widget _buildLeaderboard(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée de classement',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(leaderboardProvider({
          'type': _selectedType.toString(),
          'category': _selectedCategory.toString(),
          'city': _selectedCity,
        }));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: entries.length + 1,
        itemBuilder: (context, index) {
          // Top 3 Podium
          if (index == 0 && entries.length >= 3) {
            return _buildPodium(entries.sublist(0, 3));
          }

          final entryIndex = index == 0 ? 0 : index - 1;
          if (entryIndex >= entries.length) return const SizedBox();

          // Skip top 3 if podium is shown
          if (index == 0) return const SizedBox();
          if (index <= 3 && entries.length >= 3) return const SizedBox();

          final entry = entries[entryIndex];
          return _buildLeaderboardCard(entry);
        },
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> topThree) {
    // Reorder: 2nd, 1st, 3rd
    final ordered = [
      if (topThree.length > 1) topThree[1], // 2nd
      topThree[0], // 1st
      if (topThree.length > 2) topThree[2], // 3rd
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[50]!, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: ordered.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final actualRank = player.rank;

          // Heights: 2nd=100, 1st=130, 3rd=80
          final heights = [100.0, 130.0, 80.0];
          final colors = [Colors.grey, Colors.amber, Colors.brown];
          final medals = ['🥈', '🥇', '🥉'];

          return _buildPodiumPosition(
            player,
            actualRank,
            heights[index],
            colors[index],
            medals[index],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPodiumPosition(
    LeaderboardEntry entry,
    int rank,
    double height,
    Color color,
    String medal,
  ) {
    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: rank == 1 ? 35 : 30,
              backgroundColor: color,
              child: Text(
                entry.user.firstName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: rank == 1 ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (entry.user.isPremium)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Name
        SizedBox(
          width: 80,
          child: Text(
            '${entry.user.firstName} ${entry.user.lastName[0]}.',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // XP
        Text(
          '${entry.totalXP} XP',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        // Podium
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                medal,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry) {
    final rankColor = _getRankColor(entry.rank);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: entry.isCurrentUser ? AppColors.primary.withOpacity(0.1) : null,
      child: ListTile(
        leading: SizedBox(
          width: 50,
          child: Row(
            children: [
              // Rank
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${entry.user.firstName} ${entry.user.lastName}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (entry.user.isPremium)
              const Icon(Icons.workspace_premium, size: 16, color: Colors.amber),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(Icons.star, size: 14, color: Colors.amber[700]),
            const SizedBox(width: 4),
            Text('Niveau ${entry.user.level}'),
            const SizedBox(width: 12),
            const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
            const SizedBox(width: 4),
            Text('${entry.currentStreak} jours'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalXP} XP',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${entry.stakesCompleted} stakes',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        onTap: () => _showUserProfile(entry),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return Colors.amber;
    if (rank <= 10) return Colors.orange;
    if (rank <= 50) return Colors.blue;
    return Colors.grey;
  }

  String _getCategoryName(LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.all:
        return 'Toutes catégories';
      case LeaderboardCategory.fitness:
        return 'Fitness';
      case LeaderboardCategory.learning:
        return 'Apprentissage';
      case LeaderboardCategory.productivity:
        return 'Productivité';
      case LeaderboardCategory.finance:
        return 'Finance';
      case LeaderboardCategory.personal:
        return 'Développement';
      case LeaderboardCategory.family:
        return 'Famille';
      case LeaderboardCategory.creativity:
        return 'Créativité';
      case LeaderboardCategory.home:
        return 'Maison';
      case LeaderboardCategory.digital:
        return 'Digital';
    }
  }

  void _showUserProfile(LeaderboardEntry entry) {
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // User Profile Header
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    entry.user.firstName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${entry.user.firstName} ${entry.user.lastName}',
                  style: AppTextStyles.headingLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rang #${entry.rank} • Niveau ${entry.user.level}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('XP Total', '${entry.totalXP}', Icons.stars),
                    _buildStatColumn('Stakes', '${entry.stakesCompleted}', Icons.check_circle),
                    _buildStatColumn('Victoires', '${entry.challengesWon}', Icons.emoji_events),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Gains', '${entry.totalEarnings.toStringAsFixed(0)}€', Icons.euro),
                    _buildStatColumn('Série', '${entry.currentStreak} j', Icons.local_fire_department),
                  ],
                ),
                const SizedBox(height: 32),
                // Actions
                if (!entry.isCurrentUser) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Add friend
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Demande d\'ami envoyée à ${entry.user.firstName}'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Ajouter en ami'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Challenge user
                    },
                    icon: const Icon(Icons.sports_mma),
                    label: const Text('Défier'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headingMedium.copyWith(
            fontWeight: FontWeight.bold,
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
}
