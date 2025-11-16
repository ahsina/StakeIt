import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/stats_model.dart';
import '../repositories/stats_repository.dart';

// User stats provider
final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getUserStats();
});

// Category stats provider
final categoryStatsProvider = FutureProvider<List<CategoryStatsModel>>((ref) async {
  final repository = ref.watch(statsRepositoryProvider);
  return repository.getCategoryStats();
});

// Activity stats provider with date range
final activityStatsProvider = FutureProvider.family<List<DailyActivityModel>, DateRange>(
  (ref, dateRange) async {
    final repository = ref.watch(statsRepositoryProvider);
    return repository.getActivityStats(
      startDate: dateRange.startDate,
      endDate: dateRange.endDate,
    );
  },
);

// Helper class for date range
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}
