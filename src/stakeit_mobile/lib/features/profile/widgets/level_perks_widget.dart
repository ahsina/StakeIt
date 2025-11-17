import 'package:flutter/material.dart';
import '../../../core/theme/app_constants.dart';

// Level Perks System - Shows benefits unlocked at each level
class LevelPerksWidget extends StatelessWidget {
  final int currentLevel;

  const LevelPerksWidget({super.key, required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Avantages de niveau',
                  style: AppTextStyles.headingMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildPerksList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPerksList() {
    final perks = [
      _Perk(level: 5, title: 'Commission réduite 9%', icon: Icons.discount, unlocked: currentLevel >= 5),
      _Perk(level: 10, title: 'Badge personnalisé', icon: Icons.badge, unlocked: currentLevel >= 10),
      _Perk(level: 15, title: 'Commission réduite 8%', icon: Icons.discount, unlocked: currentLevel >= 15),
      _Perk(level: 20, title: 'Accès challenges premium', icon: Icons.stars, unlocked: currentLevel >= 20),
      _Perk(level: 25, title: 'Commission réduite 7%', icon: Icons.discount, unlocked: currentLevel >= 25),
      _Perk(level: 30, title: 'Avatar animé', icon: Icons.emoji_emotions, unlocked: currentLevel >= 30),
      _Perk(level: 35, title: 'Commission réduite 6%', icon: Icons.discount, unlocked: currentLevel >= 35),
      _Perk(level: 40, title: 'Créer des leagues privées', icon: Icons.groups, unlocked: currentLevel >= 40),
      _Perk(level: 50, title: 'Commission réduite 5%', icon: Icons.discount, unlocked: currentLevel >= 50),
      _Perk(level: 50, title: 'Statut Légende', icon: Icons.military_tech, unlocked: currentLevel >= 50),
    ];

    return perks.map((perk) => _buildPerkTile(perk)).toList();
  }

  Widget _buildPerkTile(_Perk perk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: perk.unlocked ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: perk.unlocked ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: perk.unlocked ? Colors.green : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              perk.unlocked ? Icons.check : perk.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perk.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: perk.unlocked ? Colors.black : Colors.grey[600],
                  ),
                ),
                Text(
                  'Niveau ${perk.level}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!perk.unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${perk.level - currentLevel} niveaux',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[900],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Perk {
  final int level;
  final String title;
  final IconData icon;
  final bool unlocked;

  _Perk({
    required this.level,
    required this.title,
    required this.icon,
    required this.unlocked,
  });
}

// Commission Display Widget - Shows current commission rate
class CommissionDisplayWidget extends StatelessWidget {
  final int level;

  const CommissionDisplayWidget({super.key, required this.level});

  double get commissionRate {
    if (level >= 50) return 0.05;
    if (level >= 35) return 0.06;
    if (level >= 25) return 0.07;
    if (level >= 15) return 0.08;
    if (level >= 5) return 0.09;
    return 0.10;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.percent, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Votre commission actuelle',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    '${(commissionRate * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            if (level < 50)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Prochain palier',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Niveau ${_getNextCommissionLevel(level)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  int _getNextCommissionLevel(int currentLevel) {
    if (currentLevel < 5) return 5;
    if (currentLevel < 15) return 15;
    if (currentLevel < 25) return 25;
    if (currentLevel < 35) return 35;
    return 50;
  }
}
