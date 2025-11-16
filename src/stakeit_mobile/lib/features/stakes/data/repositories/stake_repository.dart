import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/stake_model.dart';
import '../../../../shared/services/api_client.dart';
import '../../../../core/config/app_config.dart';

final stakeRepositoryProvider = Provider<StakeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StakeRepository(dio);
});

class StakeRepository {
  final Dio _dio;

  StakeRepository(this._dio);

  // Get my stakes
  Future<List<StakeModel>> getMyStakes({StakeStatus? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _dio.get(
        AppConfig.stakesEndpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => StakeModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get stake by ID
  Future<StakeModel> getStakeById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.stakesEndpoint}/$id');
      return StakeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Create stake
  Future<StakeModel> createStake(CreateStakeRequest request) async {
    try {
      final response = await _dio.post(
        AppConfig.stakesEndpoint,
        data: request.toJson(),
      );
      return StakeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Cancel stake
  Future<void> cancelStake(int id) async {
    try {
      await _dio.post('${AppConfig.stakesEndpoint}/$id/cancel');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Submit proof
  Future<StakeProofModel> submitProof(
      int stakeId, SubmitProofRequest request) async {
    try {
      final response = await _dio.post(
        '${AppConfig.stakesEndpoint}/$stakeId/proofs',
        data: request.toJson(),
      );
      return StakeProofModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get stake proofs
  Future<List<StakeProofModel>> getStakeProofs(int stakeId) async {
    try {
      final response =
          await _dio.get('${AppConfig.stakesEndpoint}/$stakeId/proofs');

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => StakeProofModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Settle stake
  Future<void> settleStake(int id) async {
    try {
      await _dio.post('${AppConfig.stakesEndpoint}/$id/settle');
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
