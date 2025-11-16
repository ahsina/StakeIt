import 'package:dio/dio.dart';
import '../../../../shared/models/social_model.dart';
import '../../../../core/config/app_config.dart';

class SocialRepository {
  final Dio _dio;

  SocialRepository(this._dio);

  // Friends
  Future<List<FriendModel>> getFriends() async {
    try {
      final response = await _dio.get('${AppConfig.apiEndpoint}/social/friends');
      return (response.data as List)
          .map((json) => FriendModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> removeFriend(int friendId) async {
    try {
      await _dio.delete('${AppConfig.apiEndpoint}/social/friends/$friendId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Friend Requests
  Future<List<FriendRequestModel>> getFriendRequests() async {
    try {
      final response = await _dio.get('${AppConfig.apiEndpoint}/social/friend-requests');
      return (response.data as List)
          .map((json) => FriendRequestModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<FriendRequestModel> sendFriendRequest(SendFriendRequestRequest request) async {
    try {
      final response = await _dio.post(
        '${AppConfig.apiEndpoint}/social/friend-requests',
        data: request.toJson(),
      );
      return FriendRequestModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> respondToFriendRequest(
    int requestId,
    RespondToFriendRequestRequest request,
  ) async {
    try {
      await _dio.post(
        '${AppConfig.apiEndpoint}/social/friend-requests/$requestId/respond',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> cancelFriendRequest(int requestId) async {
    try {
      await _dio.delete('${AppConfig.apiEndpoint}/social/friend-requests/$requestId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Social Feed
  Future<List<FeedItemModel>> getSocialFeed({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get(
        '${AppConfig.apiEndpoint}/social/feed',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return (response.data as List)
          .map((json) => FeedItemModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Referrals
  Future<ReferralStatsModel> getReferralStats() async {
    try {
      final response = await _dio.get('${AppConfig.apiEndpoint}/social/referrals/stats');
      return ReferralStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> redeemReferralCode(String code) async {
    try {
      await _dio.post(
        '${AppConfig.apiEndpoint}/social/referrals/redeem',
        data: {'code': code},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'Une erreur est survenue';
      return Exception(message);
    }
    return Exception('Erreur de connexion');
  }
}
