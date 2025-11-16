import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/challenge_model.dart';
import '../../../../shared/models/stake_model.dart';
import '../repositories/challenge_repository.dart';

// Challenges State
class ChallengesState {
  final List<ChallengeModel> publicChallenges;
  final List<ChallengeModel> myChallenges;
  final bool isLoading;
  final String? error;

  const ChallengesState({
    this.publicChallenges = const [],
    this.myChallenges = const [],
    this.isLoading = false,
    this.error,
  });

  ChallengesState copyWith({
    List<ChallengeModel>? publicChallenges,
    List<ChallengeModel>? myChallenges,
    bool? isLoading,
    String? error,
  }) {
    return ChallengesState(
      publicChallenges: publicChallenges ?? this.publicChallenges,
      myChallenges: myChallenges ?? this.myChallenges,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Challenges Notifier
class ChallengesNotifier extends StateNotifier<ChallengesState> {
  final ChallengeRepository _repository;

  ChallengesNotifier(this._repository) : super(const ChallengesState()) {
    loadChallenges();
  }

  // Load all challenges (both public and my challenges)
  Future<void> loadChallenges() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final publicFuture = _repository.getPublicChallenges();
      final myFuture = _repository.getMyChallenges();

      final results = await Future.wait([publicFuture, myFuture]);

      state = state.copyWith(
        publicChallenges: results[0] as List<ChallengeModel>,
        myChallenges: results[1] as List<ChallengeModel>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Load public challenges only
  Future<void> loadPublicChallenges({
    ChallengeStatus? status,
    StakeCategory? category,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final challenges = await _repository.getPublicChallenges(
        status: status,
        category: category,
      );
      state = state.copyWith(publicChallenges: challenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Load my challenges only
  Future<void> loadMyChallenges() async {
    try {
      final challenges = await _repository.getMyChallenges();
      state = state.copyWith(myChallenges: challenges);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Refresh all
  Future<void> refresh() async {
    await loadChallenges();
  }

  // Create challenge
  Future<ChallengeModel> createChallenge(CreateChallengeRequest request) async {
    try {
      final challenge = await _repository.createChallenge(request);
      await refresh();
      return challenge;
    } catch (e) {
      rethrow;
    }
  }

  // Join challenge
  Future<void> joinChallenge(int challengeId) async {
    try {
      await _repository.joinChallenge(challengeId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  // Leave challenge
  Future<void> leaveChallenge(int challengeId) async {
    try {
      await _repository.leaveChallenge(challengeId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  // Cancel challenge
  Future<void> cancelChallenge(int challengeId) async {
    try {
      await _repository.cancelChallenge(challengeId);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  // Submit proof
  Future<void> submitProof(int challengeId, SubmitProofRequest request) async {
    try {
      await _repository.submitProof(challengeId, request);
      await refresh();
    } catch (e) {
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, ChallengesState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  return ChallengesNotifier(repository);
});

// Single challenge provider
final challengeDetailProvider =
    FutureProvider.family<ChallengeModel, int>((ref, id) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallengeById(id);
});

// Leaderboard provider
final leaderboardProvider =
    FutureProvider.family<List<ChallengeParticipantModel>, int>(
        (ref, challengeId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getLeaderboard(challengeId);
});

// Messages provider
final messagesProvider =
    FutureProvider.family<List<ChallengeMessageModel>, int>(
        (ref, challengeId) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getMessages(challengeId);
});

// Convenience providers
final openChallengesProvider = Provider<List<ChallengeModel>>((ref) {
  final challengesState = ref.watch(challengesProvider);
  return challengesState.publicChallenges
      .where((c) => c.status == ChallengeStatus.open)
      .toList();
});

final activeChallengesProvider = Provider<List<ChallengeModel>>((ref) {
  final challengesState = ref.watch(challengesProvider);
  return challengesState.myChallenges
      .where((c) => c.status == ChallengeStatus.active)
      .toList();
});
