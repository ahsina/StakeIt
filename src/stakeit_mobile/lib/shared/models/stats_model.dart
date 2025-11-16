import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_model.freezed.dart';
part 'stats_model.g.dart';

@freezed
class UserStatsModel with _$UserStatsModel {
  const factory UserStatsModel({
    // Stakes stats
    required int totalStakes,
    required int activeStakes,
    required int completedStakes,
    required int failedStakes,
    required double stakesSuccessRate,

    // Challenges stats
    required int totalChallenges,
    required int activeChallenges,
    required int completedChallenges,
    required int wonChallenges,
    required double challengesWinRate,

    // Financial stats
    required double totalStaked,
    required double totalWon,
    required double totalLost,
    required double netProfit,
    required double currentBalance,

    // Streaks
    required int currentStreak,
    required int longestStreak,

    // Activity
    required int totalProofsSubmitted,
    required Map<String, int> categoryCounts,
    required List<DailyActivityModel> recentActivity,

    // Rankings
    int? globalRank,
    int? categoryRank,

    // Achievements
    required int totalBadges,
    required int level,
    required int xp,
    required int xpToNextLevel,
  }) = _UserStatsModel;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatsModelFromJson(json);
}

@freezed
class DailyActivityModel with _$DailyActivityModel {
  const factory DailyActivityModel({
    required DateTime date,
    required int stakesCompleted,
    required int proofsSubmitted,
    required double amountWon,
  }) = _DailyActivityModel;

  factory DailyActivityModel.fromJson(Map<String, dynamic> json) =>
      _$DailyActivityModelFromJson(json);
}

@freezed
class CategoryStatsModel with _$CategoryStatsModel {
  const factory CategoryStatsModel({
    required String category,
    required int count,
    required int completed,
    required double successRate,
  }) = _CategoryStatsModel;

  factory CategoryStatsModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryStatsModelFromJson(json);
}
