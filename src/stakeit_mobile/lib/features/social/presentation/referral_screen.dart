import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/utils.dart';
import '../../../shared/models/social_model.dart';
import '../data/providers/social_provider.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(referralStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programme de parrainage'),
      ),
      body: statsAsync.when(
        data: (stats) => _buildContent(context, ref, stats),
        loading: () => const LoadingIndicator(message: 'Chargement...'),
        error: (error, stack) => ErrorDisplay(
          message: ErrorMapper.mapError(error),
          onRetry: () => ref.refresh(referralStatsProvider),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ReferralStatsModel stats,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(referralStatsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Referral Code Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Votre code de parrainage',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Partagez-le avec vos amis',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stats.myReferralCode,
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton.outlined(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyCode(context, stats.myReferralCode),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              icon: const Icon(Icons.share),
                              onPressed: () => _shareCode(stats.myReferralCode),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total parrainages',
                  stats.totalReferrals.toString(),
                  Icons.people,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Réussis',
                  stats.successfulReferrals.toString(),
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            'Bonus total gagné',
            CurrencyFormatter.format(stats.totalBonusEarned),
            Icons.euro,
            AppColors.medalGold,
          ),
          const SizedBox(height: 24),

          // How it works
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comment ça marche ?',
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildHowItWorksStep(
                    '1',
                    'Partagez votre code',
                    'Envoyez votre code à vos amis',
                    Icons.share,
                  ),
                  const SizedBox(height: 12),
                  _buildHowItWorksStep(
                    '2',
                    'Ils s\'inscrivent',
                    'Vos amis créent un compte avec votre code',
                    Icons.person_add,
                  ),
                  const SizedBox(height: 12),
                  _buildHowItWorksStep(
                    '3',
                    'Vous gagnez tous les deux',
                    '10€ de bonus pour vous et votre ami',
                    Icons.celebration,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Referrals
          if (stats.recentReferrals.isNotEmpty) ...[
            Text(
              'Parrainages récents',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            ...stats.recentReferrals.map((referral) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: referral.isRedeemed
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.textSecondary.withOpacity(0.2),
                      child: Icon(
                        referral.isRedeemed ? Icons.check : Icons.pending,
                        color: referral.isRedeemed
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      referral.referredEmail ?? 'En attente',
                      style: AppTextStyles.titleSmall,
                    ),
                    subtitle: Text(
                      referral.isRedeemed
                          ? 'Utilisé ${DateFormatter.formatRelativeTime(referral.redeemedAt!)}'
                          : 'En attente d\'utilisation',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: referral.bonusEarned != null
                        ? Text(
                            '+${CurrencyFormatter.format(referral.bonusEarned!)}',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headingLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksStep(
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: AppTextStyles.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copié dans le presse-papiers'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareCode(String code) {
    Share.share(
      'Rejoignez StakeIt avec mon code de parrainage: $code\n\n'
      'Nous recevrons tous les deux 10€ de bonus ! 🎉\n\n'
      'Téléchargez l\'app et utilisez ce code lors de votre inscription.',
      subject: 'Rejoignez StakeIt et gagnez 10€',
    );
  }
}
