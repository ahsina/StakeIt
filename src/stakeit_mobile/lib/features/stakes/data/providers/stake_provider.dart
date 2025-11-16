import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/stake_model.dart';
import '../repositories/stake_repository.dart';

// Stakes State
class StakesState {
  final List<StakeModel> stakes;
  final bool isLoading;
  final String? error;
  final StakeStatus? currentFilter;

  const StakesState({
    this.stakes = const [],
    this.isLoading = false,
    this.error,
    this.currentFilter,
  });

  StakesState copyWith({
    List<StakeModel>? stakes,
    bool? isLoading,
    String? error,
    StakeStatus? currentFilter,
  }) {
    return StakesState(
      stakes: stakes ?? this.stakes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

// Stakes Notifier
class StakesNotifier extends StateNotifier<StakesState> {
  final StakeRepository _repository;

  StakesNotifier(this._repository) : super(const StakesState()) {
    loadStakes();
  }

  // Load stakes
  Future<void> loadStakes({StakeStatus? status}) async {
    state = state.copyWith(isLoading: true, error: null, currentFilter: status);

    try {
      final stakes = await _repository.getMyStakes(status: status);
      state = state.copyWith(stakes: stakes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Refresh stakes
  Future<void> refresh() async {
    await loadStakes(status: state.currentFilter);
  }

  // Create stake
  Future<StakeModel> createStake(CreateStakeRequest request) async {
    try {
      final stake = await _repository.createStake(request);
      // Refresh list
      await refresh();
      return stake;
    } catch (e) {
      rethrow;
    }
  }

  // Cancel stake
  Future<void> cancelStake(int id) async {
    try {
      await _repository.cancelStake(id);
      // Refresh list
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  // Submit proof
  Future<StakeProofModel> submitProof(
      int stakeId, SubmitProofRequest request) async {
    try {
      final proof = await _repository.submitProof(stakeId, request);
      // Refresh list to update counts
      await refresh();
      return proof;
    } catch (e) {
      rethrow;
    }
  }

  // Filter stakes by status
  void filterByStatus(StakeStatus? status) {
    loadStakes(status: status);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final stakesProvider = StateNotifierProvider<StakesNotifier, StakesState>((ref) {
  final repository = ref.watch(stakeRepositoryProvider);
  return StakesNotifier(repository);
});

// Single stake provider
final stakeDetailProvider = FutureProvider.family<StakeModel, int>((ref, id) async {
  final repository = ref.watch(stakeRepositoryProvider);
  return repository.getStakeById(id);
});

// Stake proofs provider
final stakeProofsProvider = FutureProvider.family<List<StakeProofModel>, int>((ref, stakeId) async {
  final repository = ref.watch(stakeRepositoryProvider);
  return repository.getStakeProofs(stakeId);
});

// Convenience providers
final activeStakesProvider = Provider<List<StakeModel>>((ref) {
  final stakesState = ref.watch(stakesProvider);
  return stakesState.stakes.where((s) => s.status == StakeStatus.active).toList();
});

final completedStakesProvider = Provider<List<StakeModel>>((ref) {
  final stakesState = ref.watch(stakesProvider);
  return stakesState.stakes.where((s) => s.status == StakeStatus.completed).toList();
});

final failedStakesProvider = Provider<List<StakeModel>>((ref) {
  final stakesState = ref.watch(stakesProvider);
  return stakesState.stakes.where((s) => s.status == StakeStatus.failed).toList();
});
