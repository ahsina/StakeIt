import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/challenge_model.dart';
import '../../../../shared/models/stake_model.dart';
import '../../../../shared/services/api_client.dart';
import '../../../../core/config/app_config.dart';

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ChallengeRepository(dio);
});

class ChallengeRepository {
  final Dio _dio;

  ChallengeRepository(this._dio);

  // Get public challenges
  Future<List<ChallengeModel>> getPublicChallenges({
    ChallengeStatus? status,
    StakeCategory? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status.name;
      }
      if (category != null) {
        queryParams['category'] = category.name;
      }

      final response = await _dio.get(
        AppConfig.challengesEndpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ChallengeModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get my challenges
  Future<List<ChallengeModel>> getMyChallenges() async {
    try {
      final response = await _dio.get('${AppConfig.challengesEndpoint}/my');

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ChallengeModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get challenge by ID
  Future<ChallengeModel> getChallengeById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.challengesEndpoint}/$id');
      return ChallengeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Create challenge
  Future<ChallengeModel> createChallenge(CreateChallengeRequest request) async {
    try {
      final response = await _dio.post(
        AppConfig.challengesEndpoint,
        data: request.toJson(),
      );
      return ChallengeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Join challenge
  Future<ChallengeParticipantModel> joinChallenge(int challengeId) async {
    try {
      final response = await _dio.post(
        '${AppConfig.challengesEndpoint}/$challengeId/join',
        data: {}, // Empty body
      );
      return ChallengeParticipantModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Leave challenge
  Future<void> leaveChallenge(int challengeId) async {
    try {
      await _dio.post('${AppConfig.challengesEndpoint}/$challengeId/leave');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Cancel challenge
  Future<void> cancelChallenge(int challengeId) async {
    try {
      await _dio.post('${AppConfig.challengesEndpoint}/$challengeId/cancel');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Submit proof
  Future<void> submitProof(
      int challengeId, SubmitProofRequest request) async {
    try {
      await _dio.post(
        '${AppConfig.challengesEndpoint}/$challengeId/proofs',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get leaderboard
  Future<List<ChallengeParticipantModel>> getLeaderboard(int challengeId) async {
    try {
      final response = await _dio.get(
        '${AppConfig.challengesEndpoint}/$challengeId/leaderboard',
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ChallengeParticipantModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Send message
  Future<ChallengeMessageModel> sendMessage(
      int challengeId, SendMessageRequest request) async {
    try {
      final response = await _dio.post(
        '${AppConfig.challengesEndpoint}/$challengeId/messages',
        data: request.toJson(),
      );
      return ChallengeMessageModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get messages
  Future<List<ChallengeMessageModel>> getMessages(
      int challengeId, {int limit = 50}) async {
    try {
      final response = await _dio.get(
        '${AppConfig.challengesEndpoint}/$challengeId/messages',
        queryParameters: {'limit': limit},
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => ChallengeMessageModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Private helper to handle errors
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final message = error.response?.data['message'] ?? 'An error occurred';
      return Exception(message);
    } else {
      return Exception('Network error. Please check your connection.');
    }
  }
}
