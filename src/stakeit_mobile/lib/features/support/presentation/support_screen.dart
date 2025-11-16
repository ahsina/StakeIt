import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int? _expandedFaqIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & Aide'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Options
            Text(
              'Contactez-nous',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingS),
            _buildContactCard(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@stakeit.com',
              onTap: () {
                _showCopiedSnackbar('support@stakeit.com');
              },
            ),
            const SizedBox(height: AppSizes.paddingS),
            _buildContactCard(
              icon: Icons.chat,
              title: 'Chat en direct',
              subtitle: 'Disponible 9h-18h (Lun-Ven)',
              onTap: () {
                _showComingSoonDialog(context, 'Chat en direct');
              },
            ),
            const SizedBox(height: AppSizes.paddingS),
            _buildContactCard(
              icon: Icons.phone,
              title: 'Téléphone',
              subtitle: '+33 1 23 45 67 89',
              onTap: () {
                _showCopiedSnackbar('+33 1 23 45 67 89');
              },
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // FAQ Section
            Text(
              'Foire aux questions (FAQ)',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingS),
            ..._buildFaqList(),
            const SizedBox(height: AppSizes.paddingXL),

            // Resources
            Text(
              'Ressources utiles',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingS),
            _buildResourceCard(
              icon: Icons.book,
              title: 'Guide d\'utilisation',
              subtitle: 'Apprenez à utiliser StakeIt',
              onTap: () {
                _showComingSoonDialog(context, 'Guide d\'utilisation');
              },
            ),
            const SizedBox(height: AppSizes.paddingS),
            _buildResourceCard(
              icon: Icons.privacy_tip,
              title: 'Politique de confidentialité',
              subtitle: 'Comment nous protégeons vos données',
              onTap: () {
                _showComingSoonDialog(context, 'Politique de confidentialité');
              },
            ),
            const SizedBox(height: AppSizes.paddingS),
            _buildResourceCard(
              icon: Icons.gavel,
              title: 'Conditions d\'utilisation',
              subtitle: 'Nos termes et conditions',
              onTap: () {
                _showComingSoonDialog(context, 'Conditions d\'utilisation');
              },
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Report a Bug
            CustomButton(
              text: 'Signaler un problème',
              icon: Icons.bug_report,
              onPressed: () {
                _showReportBugDialog(context);
              },
              type: ButtonType.outlined,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
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
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: AppSizes.iconXS,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: AppSizes.iconM,
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new,
                size: AppSizes.iconS,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFaqList() {
    final faqs = [
      {
        'question': 'Comment créer un stake ?',
        'answer':
            'Pour créer un stake, allez sur l\'onglet Stakes et appuyez sur le bouton "Créer un Stake". Remplissez les détails comme le titre, la mise, la fréquence et les dates. Vous pouvez également choisir le mode de preuve (manuel, GPS ou photo).',
      },
      {
        'question': 'Comment fonctionne la preuve GPS ?',
        'answer':
            'La preuve GPS capture votre localisation actuelle lorsque vous soumettez une preuve. Assurez-vous d\'activer les services de localisation sur votre appareil et d\'autoriser StakeIt à accéder à votre position.',
      },
      {
        'question': 'Que se passe-t-il si j\'échoue un stake ?',
        'answer':
            'Si vous ne complétez pas votre stake selon les conditions définies, le montant misé est perdu. L\'argent peut être redistribué selon les règles de la plateforme ou donné à une cause caritative.',
      },
      {
        'question': 'Comment rejoindre un challenge ?',
        'answer':
            'Allez sur l\'onglet Challenges, consultez les challenges publics disponibles et appuyez sur celui qui vous intéresse. Payez les frais d\'entrée pour rejoindre le challenge et commencez à participer.',
      },
      {
        'question': 'Comment retirer mes gains ?',
        'answer':
            'Allez sur l\'onglet Wallet, vérifiez votre solde et appuyez sur "Retirer". Vous pouvez retirer vos gains vers votre compte bancaire. Le traitement peut prendre 2-5 jours ouvrables.',
      },
      {
        'question': 'Puis-je modifier un stake après l\'avoir créé ?',
        'answer':
            'Une fois qu\'un stake est créé et actif, vous ne pouvez pas modifier ses paramètres principaux (montant, fréquence, objectif). Vous pouvez toutefois l\'annuler avant qu\'il ne devienne actif.',
      },
      {
        'question': 'Comment fonctionnent les badges et les niveaux ?',
        'answer':
            'Vous gagnez des XP en complétant des stakes et des challenges. Accumulez suffisamment de XP pour monter de niveau. Les badges sont débloqués en atteignant des jalons spécifiques ou en réalisant des exploits.',
      },
      {
        'question': 'Mes données sont-elles sécurisées ?',
        'answer':
            'Oui, nous prenons la sécurité très au sérieux. Toutes les données sont cryptées et stockées de manière sécurisée. Nous ne partageons jamais vos informations personnelles avec des tiers sans votre consentement.',
      },
    ];

    return List.generate(faqs.length, (index) {
      final faq = faqs[index];
      final isExpanded = _expandedFaqIndex == index;

      return Card(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
        child: InkWell(
          onTap: () {
            setState(() {
              _expandedFaqIndex = isExpanded ? null : index;
            });
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
                        faq['question']!,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    faq['answer']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showCopiedSnackbar(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text copié dans le presse-papier'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
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

  void _showReportBugDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Titre',
                  hint: 'Résumé du problème',
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le titre est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingM),
                CustomTextField(
                  label: 'Description',
                  hint: 'Décrivez le problème en détail',
                  controller: descriptionController,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La description est requise';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          CustomButton(
            text: 'Envoyer',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Merci pour votre signalement. Notre équipe va examiner le problème.',
                    ),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 3),
                  ),
                );
                titleController.dispose();
                descriptionController.dispose();
              }
            },
            type: ButtonType.primary,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
