import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';
import '../../shared/models/stake_model.dart';
import '../../shared/models/challenge_model.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.isLarge = false,
  });

  factory StatusBadge.fromStakeStatus(StakeStatus status, {bool isLarge = false}) {
    String text;
    Color color;
    IconData icon;

    switch (status) {
      case StakeStatus.active:
        text = 'Actif';
        color = AppColors.stakeActive;
        icon = Icons.play_circle;
        break;
      case StakeStatus.completed:
        text = 'Complété';
        color = AppColors.stakeCompleted;
        icon = Icons.check_circle;
        break;
      case StakeStatus.failed:
        text = 'Échoué';
        color = AppColors.stakeFailed;
        icon = Icons.cancel;
        break;
      case StakeStatus.cancelled:
        text = 'Annulé';
        color = AppColors.stakeCancelled;
        icon = Icons.block;
        break;
    }

    return StatusBadge(
      text: text,
      color: color,
      icon: icon,
      isLarge: isLarge,
    );
  }

  factory StatusBadge.fromChallengeStatus(ChallengeStatus status, {bool isLarge = false}) {
    String text;
    Color color;
    IconData icon;

    switch (status) {
      case ChallengeStatus.open:
        text = 'Ouvert';
        color = AppColors.challengeOpen;
        icon = Icons.door_front_door;
        break;
      case ChallengeStatus.active:
        text = 'En cours';
        color = AppColors.challengeActive;
        icon = Icons.play_circle;
        break;
      case ChallengeStatus.completed:
        text = 'Terminé';
        color = AppColors.challengeCompleted;
        icon = Icons.check_circle;
        break;
      case ChallengeStatus.cancelled:
        text = 'Annulé';
        color = AppColors.challengeCancelled;
        icon = Icons.cancel;
        break;
    }

    return StatusBadge(
      text: text,
      color: color,
      icon: icon,
      isLarge: isLarge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? AppSizes.paddingM : AppSizes.paddingS,
        vertical: isLarge ? AppSizes.paddingS : AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isLarge ? AppSizes.radiusM : AppSizes.radiusS),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: isLarge ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isLarge ? AppSizes.iconS : AppSizes.iconXS,
              color: color,
            ),
            SizedBox(width: isLarge ? AppSizes.paddingS : AppSizes.paddingXS),
          ],
          Text(
            text,
            style: (isLarge ? AppTextStyles.labelMedium : AppTextStyles.labelSmall).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final StakeCategory category;
  final bool showLabel;

  const CategoryBadge({
    super.key,
    required this.category,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIcon();
    final color = _getColor();
    final label = _getLabel();

    if (!showLabel) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.paddingS),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(iconData, color: color, size: AppSizes.iconS),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: color, size: AppSizes.iconS),
          const SizedBox(width: AppSizes.paddingS),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (category) {
      case StakeCategory.fitness:
        return Icons.fitness_center;
      case StakeCategory.education:
        return Icons.school;
      case StakeCategory.productivity:
        return Icons.work;
      case StakeCategory.finance:
        return Icons.account_balance;
      case StakeCategory.personalDevelopment:
        return Icons.self_improvement;
      case StakeCategory.family:
        return Icons.family_restroom;
      case StakeCategory.creativity:
        return Icons.palette;
      case StakeCategory.home:
        return Icons.home;
      case StakeCategory.digitalDetox:
        return Icons.phone_disabled;
    }
  }

  Color _getColor() {
    switch (category) {
      case StakeCategory.fitness:
        return AppColors.categoryFitness;
      case StakeCategory.education:
        return AppColors.categoryEducation;
      case StakeCategory.productivity:
        return AppColors.categoryProductivity;
      case StakeCategory.finance:
        return AppColors.categoryFinance;
      case StakeCategory.personalDevelopment:
        return AppColors.categoryPersonalDevelopment;
      case StakeCategory.family:
        return AppColors.categoryFamily;
      case StakeCategory.creativity:
        return AppColors.categoryCreativity;
      case StakeCategory.home:
        return AppColors.categoryHome;
      case StakeCategory.digitalDetox:
        return AppColors.categoryDigitalDetox;
    }
  }

  String _getLabel() {
    switch (category) {
      case StakeCategory.fitness:
        return 'Fitness';
      case StakeCategory.education:
        return 'Éducation';
      case StakeCategory.productivity:
        return 'Productivité';
      case StakeCategory.finance:
        return 'Finance';
      case StakeCategory.personalDevelopment:
        return 'Développement';
      case StakeCategory.family:
        return 'Famille';
      case StakeCategory.creativity:
        return 'Créativité';
      case StakeCategory.home:
        return 'Maison';
      case StakeCategory.digitalDetox:
        return 'Digital Detox';
    }
  }
}
