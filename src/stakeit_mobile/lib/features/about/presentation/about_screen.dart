import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // App Name and Version
            Text(
              'StakeIt',
              style: AppTextStyles.displayLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Text(
                'Stable',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Description
            Text(
              'L\'application de motivation ultime',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'StakeIt vous aide à atteindre vos objectifs en misant de l\'argent réel. '
              'Créez des stakes personnels, rejoignez des challenges communautaires et '
              'développez de meilleures habitudes grâce à la responsabilité financière.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingXXL),

            // Features
            _buildFeatureCard(
              icon: Icons.flag,
              title: 'Stakes Personnels',
              description: 'Créez vos propres défis et misez pour rester motivé',
            ),
            const SizedBox(height: AppSizes.paddingS),
            _buildFeatureCard(
              icon: Icons.emoji_events,
              title: 'Challenges Communautaires',
              description: 'Affrontez d\'autres utilisateurs pour des récompenses',
            ),
            const SizedBox(height: AppSizes.paddingS),
            _buildFeatureCard(
              icon: Icons.location_on,
              title: 'Preuves GPS & Photos',
              description: 'Validez vos accomplissements avec des preuves vérifiables',
            ),
            const SizedBox(height: AppSizes.paddingS),
            _buildFeatureCard(
              icon: Icons.analytics,
              title: 'Statistiques Détaillées',
              description: 'Suivez vos progrès et vos performances',
            ),
            const SizedBox(height: AppSizes.paddingXXL),

            // Team & Credits
            Text(
              'Équipe & Crédits',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingM),
            InfoCard(
              type: InfoCardType.info,
              title: 'Développé avec ❤️',
              subtitle: 'Par l\'équipe StakeIt\n© 2025 StakeIt. Tous droits réservés.',
            ),
            const SizedBox(height: AppSizes.paddingXXL),

            // Links
            Text(
              'Liens utiles',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingM),
            CustomButton(
              text: 'Site web',
              icon: Icons.language,
              onPressed: () {
                _showComingSoonDialog(context, 'Site web');
              },
              type: ButtonType.outlined,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSizes.paddingS),
            CustomButton(
              text: 'Blog',
              icon: Icons.article,
              onPressed: () {
                _showComingSoonDialog(context, 'Blog');
              },
              type: ButtonType.outlined,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSizes.paddingS),
            CustomButton(
              text: 'Support',
              icon: Icons.help,
              onPressed: () {
                context.go('${AppRoutes.home}/support');
              },
              type: ButtonType.outlined,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSizes.paddingXXL),

            // Social Media
            Text(
              'Suivez-nous',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onPressed: () {
                    _showComingSoonDialog(context, 'Facebook');
                  },
                ),
                const SizedBox(width: AppSizes.paddingM),
                _buildSocialButton(
                  icon: Icons.camera_alt,
                  label: 'Instagram',
                  onPressed: () {
                    _showComingSoonDialog(context, 'Instagram');
                  },
                ),
                const SizedBox(width: AppSizes.paddingM),
                _buildSocialButton(
                  icon: Icons.track_changes,
                  label: 'Twitter',
                  onPressed: () {
                    _showComingSoonDialog(context, 'Twitter');
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingXXL),

            // Legal
            Text(
              'Informations légales',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingM),
            _buildLegalLink(
              context,
              'Politique de confidentialité',
              () => _showComingSoonDialog(context, 'Politique de confidentialité'),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            _buildLegalLink(
              context,
              'Conditions d\'utilisation',
              () => _showComingSoonDialog(context, 'Conditions d\'utilisation'),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            _buildLegalLink(
              context,
              'Licences open source',
              () => _showLicensesDialog(context),
            ),
            const SizedBox(height: AppSizes.paddingXXL),

            // Build Info
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    'Informations de build',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  _buildInfoRow('Version', '1.0.0'),
                  _buildInfoRow('Build', '100'),
                  _buildInfoRow('Plateforme', 'Flutter'),
                  _buildInfoRow('Framework', 'Riverpod 2.5.1'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppSizes.iconM,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(AppSizes.paddingS),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: AppSizes.iconL),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLink(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: AppSizes.iconXS,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bientôt disponible'),
        content: Text('$feature sera bientôt disponible.'),
        actions: [
          CustomButton(
            text: 'OK',
            onPressed: () => Navigator.pop(context),
            type: ButtonType.primary,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }

  void _showLicensesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Licences open source'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cette application utilise les packages open source suivants :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildLicenseItem('Flutter', 'BSD 3-Clause License'),
              _buildLicenseItem('Riverpod', 'MIT License'),
              _buildLicenseItem('Go Router', 'BSD 3-Clause License'),
              _buildLicenseItem('Freezed', 'MIT License'),
              _buildLicenseItem('Dio', 'MIT License'),
              _buildLicenseItem('Firebase', 'Apache 2.0 License'),
              _buildLicenseItem('Geolocator', 'MIT License'),
              _buildLicenseItem('Image Picker', 'Apache 2.0 License'),
              const SizedBox(height: 16),
              const Text(
                'Merci à tous les contributeurs de ces projets !',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: 'Fermer',
            onPressed: () => Navigator.pop(context),
            type: ButtonType.primary,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseItem(String package, String license) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            package,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            license,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
