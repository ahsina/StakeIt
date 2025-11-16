import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/utils.dart';
import '../../../shared/models/social_model.dart';
import '../data/providers/social_provider.dart';

class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(socialFeedProvider.notifier).loadFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(socialFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fil d\'actualité'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(socialFeedProvider.notifier).refresh(),
        child: feedState.isLoading && feedState.feedItems.isEmpty
            ? const LoadingIndicator(message: 'Chargement du fil...')
            : feedState.error != null && feedState.feedItems.isEmpty
                ? ErrorDisplay(
                    message: feedState.error!.toString(),
                    onRetry: () => ref.read(socialFeedProvider.notifier).refresh(),
                  )
                : feedState.feedItems.isEmpty
                    ? const EmptyState(
                        icon: Icons.feed_outlined,
                        title: 'Aucune activité',
                        subtitle:
                            'Ajoutez des amis pour voir leurs activités ici',
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: feedState.feedItems.length +
                            (feedState.isLoading ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSizes.paddingS),
                        itemBuilder: (context, index) {
                          if (index >= feedState.feedItems.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final item = feedState.feedItems[index];
                          return _buildFeedItem(context, item);
                        },
                      ),
      ),
    );
  }

  Widget _buildFeedItem(BuildContext context, FeedItemModel item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                AvatarWidget(
                  name: item.userFullName,
                  imageUrl: item.userAvatarUrl,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.userFullName,
                        style: AppTextStyles.titleSmall,
                      ),
                      Text(
                        DateFormatter.formatRelativeTime(item.createdAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item.iconEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              item.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (item.description != null) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            // Metadata
            if (item.metadata != null && item.metadata!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _buildMetadata(context, item),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, FeedItemModel item) {
    final metadata = item.metadata!;

    switch (item.itemType) {
      case FeedItemType.stakeCompleted:
      case FeedItemType.stakeFailed:
        return Row(
          children: [
            if (metadata['amount'] != null) ...[
              const Icon(Icons.euro, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${metadata['amount']} €',
                style: AppTextStyles.bodySmall,
              ),
            ],
            if (metadata['category'] != null) ...[
              const SizedBox(width: 16),
              const Icon(Icons.category, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                metadata['category'],
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        );

      case FeedItemType.challengeWon:
        return Row(
          children: [
            if (metadata['prize'] != null) ...[
              const Icon(Icons.emoji_events, size: 16, color: AppColors.medalGold),
              const SizedBox(width: 4),
              Text(
                '+${metadata['prize']} €',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (metadata['rank'] != null) ...[
              const SizedBox(width: 16),
              Text(
                'Rang #${metadata['rank']}',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        );

      case FeedItemType.badgeEarned:
        return Row(
          children: [
            const Icon(Icons.military_tech, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              metadata['badgeName'] ?? 'Badge',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );

      case FeedItemType.levelUp:
        return Row(
          children: [
            const Icon(Icons.trending_up, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              'Niveau ${metadata['newLevel']}',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        );

      case FeedItemType.streakMilestone:
        return Row(
          children: [
            Icon(Icons.local_fire_department, size: 16, color: Colors.orange[700]),
            const SizedBox(width: 4),
            Text(
              '${metadata['streakDays']} jours consécutifs',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
