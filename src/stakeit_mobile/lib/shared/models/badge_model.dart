import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge_model.freezed.dart';
part 'badge_model.g.dart';

@freezed
class BadgeModel with _$BadgeModel {
  const factory BadgeModel({
    required int id,
    required String name,
    required String description,
    required String iconUrl,
    required int xpReward,
    required DateTime? earnedAt,
  }) = _BadgeModel;

  factory BadgeModel.fromJson(Map<String, dynamic> json) =>
      _$$BadgeModelFromJson(json);
}

extension BadgeModelX on BadgeModel {
  bool get isEarned => earnedAt != null;
}

@freezed
class UserStatsModel with _$UserStatsModel {
  const factory UserStatsModel({
    required int totalStakes,
    required int activeStakes,
    required int completedStakes,
    required int failedStakes,
    required int totalChallenges,
    required int activeChallenges,
    required int wonChallenges,
    required double totalStaked,
    required double totalWon,
    required double totalLost,
    required int currentLevel,
    required int totalXP,
    required int currentStreak,
    required int longestStreak,
    required double successRate,
    required List<BadgeModel> badges,
  }) = _UserStatsModel;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$$UserStatsModelFromJson(json);
}

extension UserStatsModelX on UserStatsModel {
  int get xpForNextLevel => currentLevel * 100;

  double get xpProgress => (totalXP % xpForNextLevel) / xpForNextLevel;

  int get earnedBadgesCount => badges.where((b) => b.isEarned).length;

  double get netProfit => totalWon - totalLost;
}
