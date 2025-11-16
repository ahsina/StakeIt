import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../shared/models/social_model.dart';
import '../repositories/social_repository.dart';
import '../../../../shared/services/dio_client.dart';

// Repository Provider
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SocialRepository(dio);
});

// Friends State
class FriendsState {
  final List<FriendModel> friends;
  final bool isLoading;
  final Exception? error;

  FriendsState({
    required this.friends,
    required this.isLoading,
    this.error,
  });

  FriendsState copyWith({
    List<FriendModel>? friends,
    bool? isLoading,
    Exception? error,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Friends Provider
class FriendsNotifier extends StateNotifier<FriendsState> {
  final SocialRepository _repository;

  FriendsNotifier(this._repository)
      : super(FriendsState(friends: [], isLoading: false));

  Future<void> loadFriends() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final friends = await _repository.getFriends();
      state = state.copyWith(friends: friends, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e is Exception ? e : Exception(e.toString()),
        isLoading: false,
      );
    }
  }

  Future<void> removeFriend(int friendId) async {
    try {
      await _repository.removeFriend(friendId);
      state = state.copyWith(
        friends: state.friends.where((f) => f.id != friendId).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() => loadFriends();
}

final friendsProvider =
    StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  final repository = ref.watch(socialRepositoryProvider);
  final notifier = FriendsNotifier(repository);
  notifier.loadFriends();
  return notifier;
});

// Friend Requests State
class FriendRequestsState {
  final List<FriendRequestModel> requests;
  final bool isLoading;
  final Exception? error;

  FriendRequestsState({
    required this.requests,
    required this.isLoading,
    this.error,
  });

  FriendRequestsState copyWith({
    List<FriendRequestModel>? requests,
    bool? isLoading,
    Exception? error,
  }) {
    return FriendRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Friend Requests Provider
class FriendRequestsNotifier extends StateNotifier<FriendRequestsState> {
  final SocialRepository _repository;

  FriendRequestsNotifier(this._repository)
      : super(FriendRequestsState(requests: [], isLoading: false));

  Future<void> loadRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final requests = await _repository.getFriendRequests();
      state = state.copyWith(requests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e is Exception ? e : Exception(e.toString()),
        isLoading: false,
      );
    }
  }

  Future<void> sendFriendRequest(String receiverEmail) async {
    try {
      final request = SendFriendRequestRequest(receiverEmail: receiverEmail);
      await _repository.sendFriendRequest(request);
      await loadRequests();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> respondToRequest(int requestId, bool accept) async {
    try {
      final request = RespondToFriendRequestRequest(accept: accept);
      await _repository.respondToFriendRequest(requestId, request);
      await loadRequests();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelRequest(int requestId) async {
    try {
      await _repository.cancelFriendRequest(requestId);
      state = state.copyWith(
        requests: state.requests.where((r) => r.id != requestId).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() => loadRequests();
}

final friendRequestsProvider =
    StateNotifierProvider<FriendRequestsNotifier, FriendRequestsState>((ref) {
  final repository = ref.watch(socialRepositoryProvider);
  final notifier = FriendRequestsNotifier(repository);
  notifier.loadRequests();
  return notifier;
});

// Social Feed State
class SocialFeedState {
  final List<FeedItemModel> feedItems;
  final bool isLoading;
  final bool hasMore;
  final Exception? error;

  SocialFeedState({
    required this.feedItems,
    required this.isLoading,
    required this.hasMore,
    this.error,
  });

  SocialFeedState copyWith({
    List<FeedItemModel>? feedItems,
    bool? isLoading,
    bool? hasMore,
    Exception? error,
  }) {
    return SocialFeedState(
      feedItems: feedItems ?? this.feedItems,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

// Social Feed Provider
class SocialFeedNotifier extends StateNotifier<SocialFeedState> {
  final SocialRepository _repository;
  int _currentPage = 1;

  SocialFeedNotifier(this._repository)
      : super(SocialFeedState(
          feedItems: [],
          isLoading: false,
          hasMore: true,
        ));

  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(feedItems: [], hasMore: true);
    }

    if (!state.hasMore && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final newItems = await _repository.getSocialFeed(page: _currentPage);

      final updatedItems = refresh
          ? newItems
          : [...state.feedItems, ...newItems];

      state = state.copyWith(
        feedItems: updatedItems,
        isLoading: false,
        hasMore: newItems.length >= 20,
      );

      if (newItems.isNotEmpty) {
        _currentPage++;
      }
    } catch (e) {
      state = state.copyWith(
        error: e is Exception ? e : Exception(e.toString()),
        isLoading: false,
      );
    }
  }

  Future<void> refresh() => loadFeed(refresh: true);
}

final socialFeedProvider =
    StateNotifierProvider<SocialFeedNotifier, SocialFeedState>((ref) {
  final repository = ref.watch(socialRepositoryProvider);
  final notifier = SocialFeedNotifier(repository);
  notifier.loadFeed();
  return notifier;
});

// Referral Stats Provider
final referralStatsProvider = FutureProvider<ReferralStatsModel>((ref) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getReferralStats();
});
