import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/utils.dart';
import '../../../shared/models/stats_model.dart';
import '../data/providers/stats_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Vue d\'ensemble'),
            Tab(text: 'Catégories'),
            Tab(text: 'Activité'),
          ],
        ),
      ),
      body: statsState.when(
        loading: () => const LoadingIndicator(
          message: 'Chargement de vos statistiques...',
        ),
        error: (error, _) => ErrorDisplay(
          message: ErrorMapper.mapError(error),
          onRetry: () => ref.refresh(userStatsProvider),
        ),
        data: (stats) => TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(stats: stats),
            const _CategoriesTab(),
            const _ActivityTab(),
          ],
        ),
      ),
    );
  }
}

// Overview Tab
class _OverviewTab extends StatelessWidget {
  final UserStatsModel stats;

  const _OverviewTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh handled by provider
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level and XP
            InfoCard(
              type: InfoCardType.gradient,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Niveau ${stats.level}',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stats.totalBadges} badges débloqués',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.military_tech,
                          color: Colors.white,
                          size: AppSizes.iconL,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  ProgressBar.xp(
                    current: stats.xp,
                    target: stats.xpToNextLevel,
                    color: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats.xp} / ${stats.xpToNextLevel} XP',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Financial Overview
            Text(
              'Finances',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Total misé',
                    value: CurrencyFormatter.format(stats.totalStaked),
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Gains',
                    value: CurrencyFormatter.format(stats.totalWon),
                    valueColor: AppColors.success,
                    icon: Icons.monetization_on,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Pertes',
                    value: CurrencyFormatter.format(stats.totalLost),
                    valueColor: AppColors.error,
                    icon: Icons.money_off,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Bénéfice net',
                    value: CurrencyFormatter.formatWithSign(stats.netProfit),
                    valueColor: stats.netProfit >= 0
                        ? AppColors.success
                        : AppColors.error,
                    icon: Icons.account_balance,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Stakes Overview
            Text(
              'Stakes',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Total',
                    value: stats.totalStakes.toString(),
                    icon: Icons.flag,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Actifs',
                    value: stats.activeStakes.toString(),
                    valueColor: AppColors.primary,
                    icon: Icons.play_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Réussis',
                    value: stats.completedStakes.toString(),
                    valueColor: AppColors.success,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Taux de succès',
                    value: '${stats.stakesSuccessRate.toStringAsFixed(1)}%',
                    valueColor: stats.stakesSuccessRate >= 50
                        ? AppColors.success
                        : AppColors.error,
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Challenges Overview
            Text(
              'Challenges',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Total',
                    value: stats.totalChallenges.toString(),
                    icon: Icons.emoji_events,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Gagnés',
                    value: stats.wonChallenges.toString(),
                    valueColor: AppColors.success,
                    icon: Icons.emoji_events,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingS),
            InfoCard(
              type: InfoCardType.stat,
              title: 'Taux de victoire',
              value: '${stats.challengesWinRate.toStringAsFixed(1)}%',
              valueColor: stats.challengesWinRate >= 50
                  ? AppColors.success
                  : AppColors.error,
              icon: Icons.military_tech,
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Streaks
            Text(
              'Séries',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Série actuelle',
                    value: '${stats.currentStreak} jours',
                    valueColor: AppColors.primary,
                    icon: Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: InfoCard(
                    type: InfoCardType.stat,
                    title: 'Record',
                    value: '${stats.longestStreak} jours',
                    valueColor: AppColors.medalGold,
                    icon: Icons.emoji_events,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Rankings (if available)
            if (stats.globalRank != null || stats.categoryRank != null) ...[
              Text(
                'Classements',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSizes.paddingS),
              if (stats.globalRank != null)
                InfoCard(
                  type: InfoCardType.info,
                  title: 'Classement global',
                  subtitle: '#${stats.globalRank}',
                  icon: Icons.leaderboard,
                ),
              if (stats.categoryRank != null) ...[
                const SizedBox(height: AppSizes.paddingS),
                InfoCard(
                  type: InfoCardType.info,
                  title: 'Classement catégorie',
                  subtitle: '#${stats.categoryRank}',
                  icon: Icons.category,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// Categories Tab
class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryStatsState = ref.watch(categoryStatsProvider);

    return categoryStatsState.when(
      loading: () => const LoadingIndicator(
        message: 'Chargement des statistiques par catégorie...',
      ),
      error: (error, _) => ErrorDisplay(
        message: ErrorMapper.mapError(error),
        onRetry: () => ref.refresh(categoryStatsProvider),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const EmptyState(
            icon: Icons.category,
            title: 'Aucune donnée',
            subtitle: 'Commencez à créer des stakes pour voir vos statistiques',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(categoryStatsProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            itemCount: categories.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.paddingS),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryStatCard(category: category);
            },
          ),
        );
      },
    );
  }
}

class _CategoryStatCard extends StatelessWidget {
  final CategoryStatsModel category;

  const _CategoryStatCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.category,
                  style: AppTextStyles.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Text(
                    '${category.count} stakes',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complétés',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.completed.toString(),
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Taux de succès',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.successRate.toStringAsFixed(1)}%',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: category.successRate >= 50
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingS),
            ProgressBar.basic(
              progress: category.successRate / 100,
              color: category.successRate >= 50
                  ? AppColors.success
                  : AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}

// Activity Tab
class _ActivityTab extends ConsumerWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get last 30 days of activity
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final dateRange = DateRange(startDate: startDate, endDate: endDate);

    final activityState = ref.watch(activityStatsProvider(dateRange));

    return activityState.when(
      loading: () => const LoadingIndicator(
        message: 'Chargement de votre activité...',
      ),
      error: (error, _) => ErrorDisplay(
        message: ErrorMapper.mapError(error),
        onRetry: () => ref.refresh(activityStatsProvider(dateRange)),
      ),
      data: (activity) {
        if (activity.isEmpty) {
          return const EmptyState(
            icon: Icons.calendar_today,
            title: 'Aucune activité',
            subtitle: 'Commencez à compléter des stakes pour voir votre activité',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.refresh(activityStatsProvider(dateRange));
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            itemCount: activity.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.paddingS),
            itemBuilder: (context, index) {
              final day = activity[index];
              return _ActivityDayCard(activity: day);
            },
          ),
        );
      },
    );
  }
}

class _ActivityDayCard extends StatelessWidget {
  final DailyActivityModel activity;

  const _ActivityDayCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormatter.formatContextualDate(activity.date),
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                _ActivityStat(
                  icon: Icons.check_circle,
                  label: 'Stakes complétés',
                  value: activity.stakesCompleted.toString(),
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSizes.paddingM),
                _ActivityStat(
                  icon: Icons.photo_camera,
                  label: 'Preuves soumises',
                  value: activity.proofsSubmitted.toString(),
                  color: AppColors.primary,
                ),
              ],
            ),
            if (activity.amountWon > 0) ...[
              const SizedBox(height: AppSizes.paddingS),
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: AppColors.success,
                    size: AppSizes.iconS,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Gains: ${CurrencyFormatter.format(activity.amountWon)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ActivityStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: AppSizes.iconS),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
