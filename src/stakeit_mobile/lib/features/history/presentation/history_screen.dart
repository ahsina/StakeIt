import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/utils.dart';
import '../../../shared/models/stake_model.dart';
import '../../../shared/models/challenge_model.dart';
import '../../../features/stakes/data/providers/stake_provider.dart';
import '../../../features/challenges/data/providers/challenge_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HistoryFilter _filter = HistoryFilter.all;
  HistorySort _sort = HistorySort.dateDesc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stakes'),
            Tab(text: 'Challenges'),
          ],
        ),
        actions: [
          // Filter button
          PopupMenuButton<HistoryFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              setState(() {
                _filter = filter;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: HistoryFilter.all,
                child: Text('Tous'),
              ),
              const PopupMenuItem(
                value: HistoryFilter.completed,
                child: Text('Complétés'),
              ),
              const PopupMenuItem(
                value: HistoryFilter.failed,
                child: Text('Échoués'),
              ),
              const PopupMenuItem(
                value: HistoryFilter.cancelled,
                child: Text('Annulés'),
              ),
            ],
          ),
          // Sort button
          PopupMenuButton<HistorySort>(
            icon: const Icon(Icons.sort),
            onSelected: (sort) {
              setState(() {
                _sort = sort;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: HistorySort.dateDesc,
                child: Text('Plus récents'),
              ),
              const PopupMenuItem(
                value: HistorySort.dateAsc,
                child: Text('Plus anciens'),
              ),
              const PopupMenuItem(
                value: HistorySort.amountDesc,
                child: Text('Montant décroissant'),
              ),
              const PopupMenuItem(
                value: HistorySort.amountAsc,
                child: Text('Montant croissant'),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StakesHistoryTab(filter: _filter, sort: _sort),
          _ChallengesHistoryTab(filter: _filter, sort: _sort),
        ],
      ),
    );
  }
}

// Stakes History Tab
class _StakesHistoryTab extends ConsumerWidget {
  final HistoryFilter filter;
  final HistorySort sort;

  const _StakesHistoryTab({
    required this.filter,
    required this.sort,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stakesState = ref.watch(stakesProvider);

    return stakesState.when(
      loading: () => const LoadingIndicator(
        message: 'Chargement de l\'historique...',
      ),
      error: (error, _) => ErrorDisplay(
        message: ErrorMapper.mapStakeError(error),
        onRetry: () => ref.refresh(stakesProvider),
      ),
      data: (stakes) {
        // Filter stakes - only show completed, failed, or cancelled
        var filteredStakes = stakes.where((stake) {
          return stake.status == StakeStatus.completed ||
              stake.status == StakeStatus.failed ||
              stake.status == StakeStatus.cancelled;
        }).toList();

        // Apply filter
        filteredStakes = _applyStakeFilter(filteredStakes, filter);

        // Apply sort
        filteredStakes = _sortStakes(filteredStakes, sort);

        if (filteredStakes.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            title: 'Aucun historique',
            subtitle: 'Vos stakes terminés apparaîtront ici',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(stakesProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            itemCount: filteredStakes.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.paddingS),
            itemBuilder: (context, index) {
              final stake = filteredStakes[index];
              return _StakeHistoryCard(stake: stake);
            },
          ),
        );
      },
    );
  }

  List<StakeModel> _applyStakeFilter(List<StakeModel> stakes, HistoryFilter filter) {
    switch (filter) {
      case HistoryFilter.all:
        return stakes;
      case HistoryFilter.completed:
        return stakes.where((s) => s.status == StakeStatus.completed).toList();
      case HistoryFilter.failed:
        return stakes.where((s) => s.status == StakeStatus.failed).toList();
      case HistoryFilter.cancelled:
        return stakes.where((s) => s.status == StakeStatus.cancelled).toList();
    }
  }

  List<StakeModel> _sortStakes(List<StakeModel> stakes, HistorySort sort) {
    final sorted = List<StakeModel>.from(stakes);
    switch (sort) {
      case HistorySort.dateDesc:
        sorted.sort((a, b) => b.endDate.compareTo(a.endDate));
        break;
      case HistorySort.dateAsc:
        sorted.sort((a, b) => a.endDate.compareTo(b.endDate));
        break;
      case HistorySort.amountDesc:
        sorted.sort((a, b) => b.amountStakedEUR.compareTo(a.amountStakedEUR));
        break;
      case HistorySort.amountAsc:
        sorted.sort((a, b) => a.amountStakedEUR.compareTo(b.amountStakedEUR));
        break;
    }
    return sorted;
  }
}

class _StakeHistoryCard extends StatelessWidget {
  final StakeModel stake;

  const _StakeHistoryCard({required this.stake});

  @override
  Widget build(BuildContext context) {
    final isSuccess = stake.status == StakeStatus.completed;
    final isCancelled = stake.status == StakeStatus.cancelled;

    return Card(
      child: InkWell(
        onTap: () {
          context.go('${AppRoutes.home}/stakes/${stake.id}');
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stake.title,
                      style: AppTextStyles.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  StatusBadge.fromStakeStatus(stake.status),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppSizes.iconXS,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Terminé ${DateFormatter.formatRelativeTime(stake.endDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Amount staked
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mise',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(stake.amountStakedEUR),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Progress
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progression',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${stake.currentCount}/${stake.targetCount}',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Result
                  if (!isCancelled)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isSuccess ? 'Gain' : 'Perte',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSuccess
                              ? '+${CurrencyFormatter.format(stake.amountStakedEUR)}'
                              : '-${CurrencyFormatter.format(stake.amountStakedEUR)}',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: isSuccess ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Challenges History Tab
class _ChallengesHistoryTab extends ConsumerWidget {
  final HistoryFilter filter;
  final HistorySort sort;

  const _ChallengesHistoryTab({
    required this.filter,
    required this.sort,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesState = ref.watch(challengesProvider);

    // Filter challenges - only show completed or cancelled
    var filteredChallenges = challengesState.myChallenges.where((challenge) {
      return challenge.status == ChallengeStatus.completed ||
          challenge.status == ChallengeStatus.cancelled;
    }).toList();

    // Apply filter
    filteredChallenges = _applyChallengeFilter(filteredChallenges, filter);

    // Apply sort
    filteredChallenges = _sortChallenges(filteredChallenges, sort);

    if (filteredChallenges.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'Aucun historique',
        subtitle: 'Vos challenges terminés apparaîtront ici',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(challengesProvider.notifier).loadMyChallenges();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: filteredChallenges.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSizes.paddingS),
        itemBuilder: (context, index) {
          final challenge = filteredChallenges[index];
          return _ChallengeHistoryCard(challenge: challenge);
        },
      ),
    );
  }

  List<ChallengeModel> _applyChallengeFilter(
    List<ChallengeModel> challenges,
    HistoryFilter filter,
  ) {
    switch (filter) {
      case HistoryFilter.all:
        return challenges;
      case HistoryFilter.completed:
        return challenges
            .where((c) => c.status == ChallengeStatus.completed)
            .toList();
      case HistoryFilter.failed:
        // For challenges, "failed" means completed but didn't win
        return challenges
            .where((c) =>
                c.status == ChallengeStatus.completed &&
                c.userRank != null &&
                c.userRank! > 1)
            .toList();
      case HistoryFilter.cancelled:
        return challenges
            .where((c) => c.status == ChallengeStatus.cancelled)
            .toList();
    }
  }

  List<ChallengeModel> _sortChallenges(
    List<ChallengeModel> challenges,
    HistorySort sort,
  ) {
    final sorted = List<ChallengeModel>.from(challenges);
    switch (sort) {
      case HistorySort.dateDesc:
        sorted.sort((a, b) => b.endDate.compareTo(a.endDate));
        break;
      case HistorySort.dateAsc:
        sorted.sort((a, b) => a.endDate.compareTo(b.endDate));
        break;
      case HistorySort.amountDesc:
        sorted.sort((a, b) => b.entryFeeEUR.compareTo(a.entryFeeEUR));
        break;
      case HistorySort.amountAsc:
        sorted.sort((a, b) => a.entryFeeEUR.compareTo(b.entryFeeEUR));
        break;
    }
    return sorted;
  }
}

class _ChallengeHistoryCard extends StatelessWidget {
  final ChallengeModel challenge;

  const _ChallengeHistoryCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final isCompleted = challenge.status == ChallengeStatus.completed;
    final isWinner = challenge.userRank != null && challenge.userRank == 1;

    return Card(
      child: InkWell(
        onTap: () {
          context.go('${AppRoutes.home}/challenges/${challenge.id}');
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      challenge.title,
                      style: AppTextStyles.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  StatusBadge.fromChallengeStatus(challenge.status),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppSizes.iconXS,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Terminé ${DateFormatter.formatRelativeTime(challenge.endDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Entry fee
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frais d\'entrée',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(challenge.entryFeeEUR),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Rank
                  if (isCompleted && challenge.userRank != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Classement',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (isWinner)
                              const Icon(
                                Icons.emoji_events,
                                color: AppColors.medalGold,
                                size: AppSizes.iconS,
                              ),
                            if (isWinner) const SizedBox(width: 4),
                            Text(
                              '#${challenge.userRank}',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: isWinner
                                    ? AppColors.medalGold
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  // Prize won
                  if (isCompleted && challenge.prizeWonEUR != null && challenge.prizeWonEUR! > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Gains',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+${CurrencyFormatter.format(challenge.prizeWonEUR!)}',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enums
enum HistoryFilter {
  all,
  completed,
  failed,
  cancelled,
}

enum HistorySort {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
}
