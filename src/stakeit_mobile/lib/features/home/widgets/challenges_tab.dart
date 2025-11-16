import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/challenge_model.dart';
import '../../../features/challenges/data/providers/challenge_provider.dart';

class ChallengesTab extends ConsumerStatefulWidget {
  const ChallengesTab({super.key});

  @override
  ConsumerState<ChallengesTab> createState() => _ChallengesTabState();
}

class _ChallengesTabState extends ConsumerState<ChallengesTab> {
  @override
  void initState() {
    super.initState();
    // Load challenges on init
    Future.microtask(() {
      ref.read(challengesProvider.notifier).loadMyChallenges();
      ref.read(challengesProvider.notifier).loadPublicChallenges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final challengesState = ref.watch(challengesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search challenges
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filter challenges
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(challengesProvider.notifier).loadMyChallenges();
          await ref.read(challengesProvider.notifier).loadPublicChallenges();
        },
        child: CustomScrollView(
          slivers: [
            // My Challenges Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Challenges',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Challenges auxquels vous participez',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // My Challenges List
            if (challengesState.isLoading && challengesState.myChallenges.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (challengesState.myChallenges.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun challenge en cours',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rejoignez un challenge public ou créez le vôtre',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final challenge = challengesState.myChallenges[index];
                      return _buildChallengeCard(context, challenge, isMyChallenge: true);
                    },
                    childCount: challengesState.myChallenges.length,
                  ),
                ),
              ),

            // Public Challenges Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Challenges Publics',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rejoignez un challenge existant',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Public Challenges List
            if (challengesState.isLoading && challengesState.publicChallenges.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (challengesState.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(challengesState.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(challengesProvider.notifier).loadPublicChallenges();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (challengesState.publicChallenges.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.public_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun challenge public disponible',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Soyez le premier à créer un challenge public !',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final challenge = challengesState.publicChallenges[index];
                      return _buildChallengeCard(context, challenge, isMyChallenge: false);
                    },
                    childCount: challengesState.publicChallenges.length,
                  ),
                ),
              ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('${AppRoutes.home}/create-challenge');
        },
        icon: const Icon(Icons.add),
        label: const Text('Créer un Challenge'),
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, ChallengeModel challenge, {required bool isMyChallenge}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.go('${AppRoutes.home}/challenges/${challenge.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _getCategoryIcon(challenge.category),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getChallengeTypeName(challenge.challengeType),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, challenge.status),
                ],
              ),
              const SizedBox(height: 16),

              // Participants and Prize
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${challenge.currentParticipants}/${challenge.maxParticipants} participants',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: challenge.currentParticipants / challenge.maxParticipants,
                          backgroundColor: Colors.grey[300],
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Cagnotte',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${challenge.totalPrizePool.toStringAsFixed(0)}€',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dates and Entry Fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDateRange(challenge.startDate, challenge.endDate),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${challenge.entryFeeEUR.toStringAsFixed(0)}€',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              // Join/Full indicator for public challenges
              if (!isMyChallenge && challenge.isFull)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Challenge complet',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCategoryIcon(StakeCategory category) {
    IconData icon;
    Color color;

    switch (category) {
      case StakeCategory.fitness:
        icon = Icons.fitness_center;
        color = Colors.red;
        break;
      case StakeCategory.education:
        icon = Icons.school;
        color = Colors.blue;
        break;
      case StakeCategory.productivity:
        icon = Icons.work;
        color = Colors.purple;
        break;
      case StakeCategory.finance:
        icon = Icons.account_balance;
        color = Colors.green;
        break;
      case StakeCategory.personalDevelopment:
        icon = Icons.self_improvement;
        color = Colors.orange;
        break;
      case StakeCategory.family:
        icon = Icons.family_restroom;
        color = Colors.pink;
        break;
      case StakeCategory.creativity:
        icon = Icons.palette;
        color = Colors.deepPurple;
        break;
      case StakeCategory.home:
        icon = Icons.home;
        color = Colors.brown;
        break;
      case StakeCategory.digitalDetox:
        icon = Icons.phone_disabled;
        color = Colors.teal;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      radius: 20,
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusChip(BuildContext context, ChallengeStatus status) {
    Color color;
    String label;

    switch (status) {
      case ChallengeStatus.pending:
        color = Colors.orange;
        label = 'En attente';
        break;
      case ChallengeStatus.active:
        color = Colors.green;
        label = 'En cours';
        break;
      case ChallengeStatus.completed:
        color = Colors.blue;
        label = 'Terminé';
        break;
      case ChallengeStatus.cancelled:
        color = Colors.red;
        label = 'Annulé';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getChallengeTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.firstToFinish:
        return 'Premier à finir';
      case ChallengeType.mostProgress:
        return 'Plus de progrès';
      case ChallengeType.survivalRace:
        return 'Course de survie';
      case ChallengeType.collaborative:
        return 'Collaboratif';
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isBefore(start)) {
      return 'Débute le ${start.day}/${start.month}';
    } else if (now.isAfter(end)) {
      return 'Terminé le ${end.day}/${end.month}';
    } else {
      final remaining = end.difference(now);
      if (remaining.inDays > 0) {
        return '${remaining.inDays}j restants';
      } else if (remaining.inHours > 0) {
        return '${remaining.inHours}h restantes';
      } else {
        return 'Se termine bientôt';
      }
    }
  }
}
