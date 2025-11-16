import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/utils.dart';
import '../../../features/auth/data/providers/auth_provider.dart';
import '../../../features/stakes/data/providers/stake_provider.dart';
import '../../../shared/models/stake_model.dart';

class StakesTab extends ConsumerStatefulWidget {
  const StakesTab({super.key});

  @override
  ConsumerState<StakesTab> createState() => _StakesTabState();
}

class _StakesTabState extends ConsumerState<StakesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    StakeStatus? filter;
    switch (index) {
      case 0:
        filter = StakeStatus.active;
        break;
      case 1:
        filter = StakeStatus.completed;
        break;
      case 2:
        filter = StakeStatus.failed;
        break;
    }
    ref.read(stakesProvider.notifier).filterByStatus(filter);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final stakesState = ref.watch(stakesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Stakes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.go('${AppRoutes.home}/notifications');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(stakesProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // User Stats Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AvatarWidget(
                              name: '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                              size: 60,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Niveau ${user?.currentLevel ?? 1}',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.local_fire_department,
                                        size: 16,
                                        color: Colors.orange[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${user?.currentStreak ?? 0} jours',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // XP Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'XP',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '${user?.totalXP ?? 0} / ${((user?.currentLevel ?? 1) * 100)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (user?.totalXP ?? 0) / ((user?.currentLevel ?? 1) * 100),
                              backgroundColor: Colors.grey[300],
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Filter Tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Actifs'),
                    Tab(text: 'Complétés'),
                    Tab(text: 'Échoués'),
                  ],
                ),
              ),
            ),

            // Stakes List
            if (stakesState.isLoading)
              const SliverFillRemaining(
                child: LoadingIndicator(message: 'Chargement des stakes...'),
              )
            else if (stakesState.error != null)
              SliverFillRemaining(
                child: ErrorDisplay(
                  message: ErrorMapper.mapStakeError(stakesState.error!),
                  onRetry: () => ref.read(stakesProvider.notifier).refresh(),
                ),
              )
            else if (stakesState.stakes.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.emoji_events_outlined,
                  title: 'Aucun stake',
                  subtitle: 'Créez votre premier stake pour commencer !',
                  actionButton: CustomButton(
                    text: 'Créer un Stake',
                    icon: Icons.add,
                    onPressed: () {
                      context.go('${AppRoutes.home}/create-stake');
                    },
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final stake = stakesState.stakes[index];
                      return _buildStakeCard(context, stake);
                    },
                    childCount: stakesState.stakes.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('${AppRoutes.home}/create-stake');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Stake'),
      ),
    );
  }

  Widget _buildStakeCard(BuildContext context, StakeModel stake) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.go('${AppRoutes.home}/stakes/${stake.id}');
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
                  _getCategoryIcon(stake.category),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stake.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stake.categoryName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${stake.amountEUR.toStringAsFixed(0)}€',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${stake.currentCount} / ${stake.requiredCount}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${stake.progressPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: stake.progressPercentage / 100,
                backgroundColor: Colors.grey[300],
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatEndDate(stake.endDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                  if (stake.isActive && !stake.isExpired)
                    Chip(
                      label: Text(
                        _formatTimeRemaining(stake.timeRemaining),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                ],
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

  String _formatEndDate(DateTime date) {
    return 'Se termine le ${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}j restants';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h restantes';
    } else {
      return '${duration.inMinutes}min restantes';
    }
  }
}
