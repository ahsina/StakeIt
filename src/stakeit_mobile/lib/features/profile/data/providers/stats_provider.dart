import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/badge_model.dart';
import '../repositories/stats_repository.dart';

// Provider for user statistics
final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getUserStats();
});

// Provider for user badges
final userBadgesProvider = FutureProvider<List<BadgeModel>>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getBadges();
});

// Provider for earned badges only
final earnedBadgesProvider = Provider<AsyncValue<List<BadgeModel>>>((ref) {
  final badgesAsync = ref.watch(userBadgesProvider);
  return badgesAsync.whenData((badges) =>
      badges.where((badge) => badge.isEarned).toList());
});

// Provider for unearned badges only
final unearnedBadgesProvider = Provider<AsyncValue<List<BadgeModel>>>((ref) {
  final badgesAsync = ref.watch(userBadgesProvider);
  return badgesAsync.whenData((badges) =>
      badges.where((badge) => !badge.isEarned).toList());
});
