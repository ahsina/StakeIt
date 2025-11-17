import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Premium Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber[700]!,
                      Colors.amber[400]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspace_premium, size: 80, color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'StakeIt Premium',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Débloquez tout le potentiel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Premium Benefits
                _buildSectionTitle('Avantages Premium'),
                _buildBenefitsList(),

                const SizedBox(height: 32),

                // Pricing Plans
                _buildSectionTitle('Choisissez votre abonnement'),
                _buildPricingPlans(context),

                const SizedBox(height: 32),

                // FAQ
                _buildSectionTitle('Questions fréquentes'),
                _buildFAQ(),

                const SizedBox(height: 32),

                // Testimonials
                _buildSectionTitle('Ce qu\'ils en pensent'),
                _buildTestimonials(),

                const SizedBox(height: 32),

                // CTA
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CustomButton(
                        text: 'Commencer l\'essai gratuit',
                        onPressed: () => _startFreeTrial(context),
                        backgroundColor: Colors.amber[700],
                        icon: Icons.stars,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '7 jours gratuits • Annulation à tout moment',
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        title,
        style: AppTextStyles.headingLarge,
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      _BenefitItem(
        icon: Icons.attach_money,
        title: 'Commission réduite',
        description: '5% au lieu de 10% sur tous vos stakes',
        color: Colors.green,
      ),
      _BenefitItem(
        icon: Icons.all_inclusive,
        title: 'Stakes illimités',
        description: 'Créez autant de stakes que vous voulez',
        color: Colors.blue,
      ),
      _BenefitItem(
        icon: Icons.analytics,
        title: 'Statistiques avancées',
        description: 'Analyses détaillées de vos performances',
        color: Colors.purple,
      ),
      _BenefitItem(
        icon: Icons.support_agent,
        title: 'Support prioritaire',
        description: 'Assistance rapide et personnalisée',
        color: Colors.orange,
      ),
      _BenefitItem(
        icon: Icons.military_tech,
        title: 'Badges exclusifs',
        description: 'Badges et récompenses réservés aux Premium',
        color: Colors.amber,
      ),
      _BenefitItem(
        icon: Icons.palette,
        title: 'Thèmes personnalisés',
        description: 'Couleurs et thèmes exclusifs',
        color: Colors.pink,
      ),
      _BenefitItem(
        icon: Icons.block,
        title: 'Sans publicité',
        description: 'Expérience 100% sans pub',
        color: Colors.red,
      ),
      _BenefitItem(
        icon: Icons.flash_on,
        title: 'Accès anticipé',
        description: 'Nouvelles fonctionnalités en avant-première',
        color: Colors.yellow,
      ),
      _BenefitItem(
        icon: Icons.emoji_events,
        title: 'Avatars animés',
        description: 'Options d\'avatar premium exclusives',
        color: Colors.cyan,
      ),
      _BenefitItem(
        icon: Icons.bolt,
        title: 'Power-ups gratuits',
        description: '3 power-ups offerts chaque mois',
        color: Colors.indigo,
      ),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: benefits.length,
      itemBuilder: (context, index) => _buildBenefitCard(benefits[index]),
    );
  }

  Widget _buildBenefitCard(_BenefitItem benefit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: benefit.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(benefit.icon, color: benefit.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    benefit.description,
                    style: AppTextStyles.bodyMedium.copyWith(
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

  Widget _buildPricingPlans(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Monthly Plan
          _buildPricingCard(
            context,
            title: 'Mensuel',
            price: '4,99€',
            period: '/mois',
            features: [
              'Tous les avantages Premium',
              'Facturation mensuelle',
              'Annulation à tout moment',
            ],
            isPopular: false,
            onTap: () => _subscribeTo(context, 'monthly'),
          ),
          const SizedBox(height: 16),
          // Yearly Plan (Popular)
          _buildPricingCard(
            context,
            title: 'Annuel',
            price: '49,99€',
            period: '/an',
            savings: 'Économisez 16%',
            features: [
              'Tous les avantages Premium',
              '2 mois offerts',
              'Meilleur rapport qualité-prix',
            ],
            isPopular: true,
            onTap: () => _subscribeTo(context, 'yearly'),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    String? savings,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isPopular ? Colors.amber[700]! : Colors.grey[300]!,
          width: isPopular ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(13),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'PLUS POPULAIRE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  title,
                  style: AppTextStyles.headingMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: isPopular ? Colors.amber[700] : AppColors.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        period,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (savings != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      savings,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: isPopular ? Colors.amber[700] : Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Choisir ce plan',
                  onPressed: onTap,
                  backgroundColor:
                      isPopular ? Colors.amber[700] : AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    final faqs = [
      _FAQItem(
        question: 'Puis-je annuler à tout moment ?',
        answer:
            'Oui, vous pouvez annuler votre abonnement Premium à tout moment depuis les paramètres. Il restera actif jusqu\'à la fin de la période payée.',
      ),
      _FAQItem(
        question: 'Que se passe-t-il après l\'essai gratuit ?',
        answer:
            'Après 7 jours d\'essai gratuit, vous serez automatiquement facturé selon le plan choisi. Vous pouvez annuler avant la fin de l\'essai sans frais.',
      ),
      _FAQItem(
        question: 'Est-ce que mes stakes existants sont affectés ?',
        answer:
            'Non, vos stakes en cours continuent normalement. Les avantages Premium (commission réduite) s\'appliquent uniquement aux nouveaux stakes créés après l\'abonnement.',
      ),
      _FAQItem(
        question: 'Puis-je passer de mensuel à annuel ?',
        answer:
            'Oui, vous pouvez changer de plan à tout moment. Le montant restant de votre abonnement actuel sera déduit du nouveau plan.',
      ),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: faqs.length,
      itemBuilder: (context, index) => _buildFAQCard(faqs[index]),
    );
  }

  Widget _buildFAQCard(_FAQItem faq) {
    return ExpansionTile(
      title: Text(
        faq.question,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            faq.answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonials() {
    final testimonials = [
      _TestimonialItem(
        name: 'Marie L.',
        rating: 5,
        comment:
            'Premium vaut vraiment le coup ! J\'ai économisé beaucoup avec la commission réduite.',
      ),
      _TestimonialItem(
        name: 'Thomas D.',
        rating: 5,
        comment:
            'Les statistiques avancées m\'aident vraiment à suivre ma progression. Top !',
      ),
      _TestimonialItem(
        name: 'Sophie M.',
        rating: 4,
        comment:
            'Super app, le Premium offre de belles fonctionnalités. Je recommande.',
      ),
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: testimonials.length,
        itemBuilder: (context, index) {
          return _buildTestimonialCard(testimonials[index]);
        },
      ),
    );
  }

  Widget _buildTestimonialCard(_TestimonialItem testimonial) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(testimonial.name[0]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testimonial.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < testimonial.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  testimonial.comment,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startFreeTrial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Démarrer l\'essai gratuit'),
        content: const Text(
          'Vous allez commencer un essai gratuit de 7 jours. Aucun paiement ne sera effectué maintenant. Vous pouvez annuler à tout moment avant la fin de l\'essai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Start free trial
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Essai gratuit activé ! Bienvenue Premium 🎉'),
                ),
              );
            },
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }

  void _subscribeTo(BuildContext context, String plan) {
    final planName = plan == 'monthly' ? 'mensuel' : 'annuel';
    final price = plan == 'monthly' ? '4,99€/mois' : '49,99€/an';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Abonnement $planName'),
        content: Text(
          'Vous allez souscrire à l\'abonnement $planName pour $price.\n\nEssai gratuit de 7 jours inclus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Process subscription
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Abonnement $planName activé !'),
                ),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _FAQItem {
  final String question;
  final String answer;

  _FAQItem({required this.question, required this.answer});
}

class _TestimonialItem {
  final String name;
  final int rating;
  final String comment;

  _TestimonialItem({
    required this.name,
    required this.rating,
    required this.comment,
  });
}
