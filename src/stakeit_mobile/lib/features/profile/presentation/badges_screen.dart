import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/badge_model.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../data/providers/stats_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(userBadgesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Badges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showBadgesInfo(context),
          ),
        ],
      ),
      body: badgesAsync.when(
        data: (badges) => _buildBadgesList(context, badges),
        loading: () => const LoadingIndicator(message: 'Chargement des badges...'),
        error: (error, stack) => ErrorDisplay(
          message: 'Erreur lors du chargement des badges',
          onRetry: () => ref.refresh(userBadgesProvider),
        ),
      ),
    );
  }

  Widget _buildBadgesList(BuildContext context, List<BadgeModel> badges) {
    if (badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.military_tech,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun badge débloqué',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Complétez des stakes et participez à des challenges pour débloquer des badges !',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Group badges by category
    final earnedBadges = badges.where((b) => b.isEarned).toList();
    final lockedBadges = badges.where((b) => !b.isEarned).toList();

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh badges
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats Header
          _buildStatsHeader(earnedBadges.length, badges.length),
          const SizedBox(height: 24),

          // Earned Badges Section
          if (earnedBadges.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Badges débloqués (${earnedBadges.length})',
                  style: AppTextStyles.headingMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBadgesGrid(context, earnedBadges, isEarned: true),
            const SizedBox(height: 32),
          ],

          // Locked Badges Section
          if (lockedBadges.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.grey[400], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Badges à débloquer (${lockedBadges.length})',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBadgesGrid(context, lockedBadges, isEarned: false),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsHeader(int earned, int total) {
    final percentage = total > 0 ? (earned / total * 100).toInt() : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Débloqués',
                  earned.toString(),
                  Icons.emoji_events,
                  Colors.amber,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _buildStatItem(
                  'Total',
                  total.toString(),
                  Icons.military_tech,
                  AppColors.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                _buildStatItem(
                  'Progression',
                  '$percentage%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: earned / (total > 0 ? total : 1),
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headingLarge.copyWith(
            color: color,
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

  Widget _buildBadgesGrid(BuildContext context, List<BadgeModel> badges, {required bool isEarned}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return _buildBadgeCard(context, badges[index], isEarned);
      },
    );
  }

  Widget _buildBadgeCard(BuildContext context, BadgeModel badge, bool isEarned) {
    return GestureDetector(
      onTap: () => _showBadgeDetail(context, badge),
      child: Card(
        elevation: isEarned ? 4 : 1,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isEarned
                ? LinearGradient(
                    colors: [
                      _getBadgeColor(badge.category),
                      _getBadgeColor(badge.category).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge Icon/Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEarned ? Colors.white : Colors.grey[200],
                ),
                child: Center(
                  child: Text(
                    _getBadgeIcon(badge.category),
                    style: TextStyle(
                      fontSize: 32,
                      color: isEarned ? _getBadgeColor(badge.category) : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Badge Name
              Text(
                badge.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEarned ? Colors.white : AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              if (isEarned && badge.earnedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(badge.earnedAt!),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isEarned ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
              if (!isEarned) ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, BadgeModel badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                // Badge Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: badge.isEarned
                        ? LinearGradient(
                            colors: [
                              _getBadgeColor(badge.category),
                              _getBadgeColor(badge.category).withOpacity(0.7),
                            ],
                          )
                        : null,
                    color: badge.isEarned ? null : Colors.grey[200],
                  ),
                  child: Center(
                    child: Text(
                      _getBadgeIcon(badge.category),
                      style: TextStyle(
                        fontSize: 48,
                        color: badge.isEarned ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Badge Name
                Text(
                  badge.name,
                  style: AppTextStyles.headingLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Badge Description
                Text(
                  badge.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Badge Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.category,
                        'Catégorie',
                        _getCategoryName(badge.category),
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.stars,
                        'Récompense XP',
                        '${badge.xpReward} XP',
                      ),
                      if (badge.isEarned && badge.earnedAt != null) ...[
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.event,
                          'Débloqué le',
                          _formatFullDate(badge.earnedAt!),
                        ),
                      ],
                      if (!badge.isEarned) ...[
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.lock_outline,
                          'Statut',
                          'Non débloqué',
                        ),
                      ],
                    ],
                  ),
                ),
                if (!badge.isEarned) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to relevant section to earn badge
                    },
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('Comment débloquer ?'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showBadgesInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('À propos des badges'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Les badges sont des récompenses que vous débloquez en accomplissant des défis spécifiques.',
            ),
            const SizedBox(height: 16),
            const Text('Catégories de badges :'),
            const SizedBox(height: 8),
            _buildBadgeCategoryInfo('🏆', 'Stakes', 'Compléter des stakes'),
            _buildBadgeCategoryInfo('🔥', 'Streaks', 'Maintenir une série'),
            _buildBadgeCategoryInfo('⚔️', 'Challenges', 'Gagner des challenges'),
            _buildBadgeCategoryInfo('💰', 'Argent', 'Économiser/gagner'),
            _buildBadgeCategoryInfo('👥', 'Social', 'Inviter des amis'),
          ],
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

  Widget _buildBadgeCategoryInfo(String emoji, String name, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.stakes:
        return Colors.blue;
      case BadgeCategory.challenges:
        return Colors.purple;
      case BadgeCategory.streaks:
        return Colors.orange;
      case BadgeCategory.financial:
        return Colors.green;
      case BadgeCategory.social:
        return Colors.pink;
    }
  }

  String _getBadgeIcon(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.stakes:
        return '🏆';
      case BadgeCategory.challenges:
        return '⚔️';
      case BadgeCategory.streaks:
        return '🔥';
      case BadgeCategory.financial:
        return '💰';
      case BadgeCategory.social:
        return '👥';
    }
  }

  String _getCategoryName(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.stakes:
        return 'Stakes';
      case BadgeCategory.challenges:
        return 'Challenges';
      case BadgeCategory.streaks:
        return 'Séries';
      case BadgeCategory.financial:
        return 'Financier';
      case BadgeCategory.social:
        return 'Social';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Hier';
    if (diff < 7) return 'Il y a $diff jours';
    if (diff < 30) return 'Il y a ${(diff / 7).floor()} sem.';
    return 'Il y a ${(diff / 30).floor()} mois';
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
