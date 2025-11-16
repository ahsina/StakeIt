import 'package:share_plus/share_plus.dart';
import '../models/stake_model.dart';
import '../models/challenge_model.dart';
import '../models/badge_model.dart';

class ShareUtil {
  /// Share a completed stake achievement
  static Future<void> shareStakeCompletion(StakeModel stake) async {
    final message = '''
🎯 J'ai réussi mon objectif sur StakeIt !

"${stake.title}"

${stake.categoryName} • ${stake.amountEUR.toStringAsFixed(0)}€
✅ ${stake.currentCount}/${stake.requiredCount} preuves

Rejoignez-moi sur StakeIt pour atteindre vos objectifs ! 💪
''';

    await Share.share(
      message,
      subject: 'Mon succès sur StakeIt',
    );
  }

  /// Share a challenge victory
  static Future<void> shareChallengeVictory(ChallengeModel challenge, int rank, double? prizeWon) async {
    final rankEmoji = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '🏆';

    final prizeText = prizeWon != null && prizeWon > 0
        ? '\n💰 Gain: ${prizeWon.toStringAsFixed(0)}€'
        : '';

    final message = '''
$rankEmoji J'ai terminé #$rank sur StakeIt !

Challenge: "${challenge.title}"

${challenge.currentParticipants} participants$prizeText

Rejoignez-moi pour relever des défis ensemble ! 🚀
''';

    await Share.share(
      message,
      subject: 'Ma victoire sur StakeIt',
    );
  }

  /// Share a badge earned
  static Future<void> shareBadgeEarned(BadgeModel badge) async {
    final message = '''
🏅 Nouveau badge débloqué sur StakeIt !

${badge.name}
${badge.description}

+${badge.xpReward} XP

Rejoignez-moi sur StakeIt pour débloquer des badges ! ⭐
''';

    await Share.share(
      message,
      subject: 'Badge débloqué sur StakeIt',
    );
  }

  /// Share a level up achievement
  static Future<void> shareLevelUp(int newLevel, int totalXP) async {
    final message = '''
⬆️ Niveau $newLevel atteint sur StakeIt !

$totalXP XP au total

Rejoignez-moi pour progresser ensemble ! 🎮
''';

    await Share.share(
      message,
      subject: 'Nouveau niveau sur StakeIt',
    );
  }

  /// Share a streak milestone
  static Future<void> shareStreakMilestone(int streakDays) async {
    final message = '''
🔥 $streakDays jours consécutifs sur StakeIt !

Je maintiens ma motivation jour après jour !

Rejoignez-moi pour construire vos habitudes ! 💪
''';

    await Share.share(
      message,
      subject: 'Série de $streakDays jours sur StakeIt',
    );
  }

  /// Share general app invitation
  static Future<void> shareAppInvitation() async {
    const message = '''
📱 Découvrez StakeIt !

L'app qui vous aide à atteindre vos objectifs grâce à la motivation financière.

💰 Misez sur vous-même
🎯 Relevez des défis
🏆 Gagnez de l'argent

Téléchargez l'app maintenant ! 🚀
''';

    await Share.share(
      message,
      subject: 'Découvrez StakeIt',
    );
  }
}
