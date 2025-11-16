import 'package:freezed_annotation/freezed_annotation.dart';
import 'stake_model.dart';

part 'challenge_model.freezed.dart';
part 'challenge_model.g.dart';

enum ChallengeStatus {
  @JsonValue('Open')
  open,
  @JsonValue('Active')
  active,
  @JsonValue('Completed')
  completed,
  @JsonValue('Cancelled')
  cancelled,
}

enum ChallengeType {
  @JsonValue('FirstToComplete')
  firstToComplete,
  @JsonValue('HighestScore')
  highestScore,
  @JsonValue('TeamBased')
  teamBased,
}

@freezed
class ChallengeModel with _$ChallengeModel {
  const factory ChallengeModel({
    required int id,
    required String title,
    String? description,
    required StakeCategory category,
    required ChallengeType challengeType,
    required ChallengeStatus status,
    required int maxParticipants,
    required int currentParticipants,
    required double entryFeeEUR,
    required double totalPrizePool,
    required DateTime startDate,
    required DateTime endDate,
    required int targetCount,
    required ProofMode proofMode,
    int? geofenceId,
    required bool allowSpectators,
    required bool isPublic,
    required DateTime createdAt,
    required int creatorId,
    required String creatorEmail,
    required String creatorName,
    required List<ChallengeParticipantModel> participants,
    int? userRank,
    double? prizeWonEUR,
  }) = _ChallengeModel;

  factory ChallengeModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeModelFromJson(json);
}

const ChallengeModel._(); // For adding computed properties

extension ChallengeModelX on ChallengeModel {
  bool get isStarted => DateTime.now().isAfter(startDate);
  bool get isEnded => DateTime.now().isAfter(endDate);
  bool get isFull => currentParticipants >= maxParticipants;

  Duration get timeUntilStart => startDate.difference(DateTime.now());
  Duration get timeRemaining => endDate.difference(DateTime.now());

  double get fillPercentage =>
      maxParticipants > 0 ? (currentParticipants / maxParticipants * 100) : 0;
}

@freezed
class ChallengeParticipantModel with _$ChallengeParticipantModel {
  const factory ChallengeParticipantModel({
    required int id,
    required int userId,
    required String userEmail,
    required String userName,
    String? userAvatarUrl,
    required int currentCount,
    required int rank,
    required bool hasCompleted,
    required DateTime joinedAt,
    required double progressPercentage,
  }) = _ChallengeParticipantModel;

  factory ChallengeParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeParticipantModelFromJson(json);
}

@freezed
class CreateChallengeRequest with _$CreateChallengeRequest {
  const factory CreateChallengeRequest({
    required String title,
    String? description,
    required StakeCategory category,
    required ChallengeType challengeType,
    required int maxParticipants,
    required double entryFeeEUR,
    required DateTime startDate,
    required DateTime endDate,
    required int targetCount,
    required ProofMode proofMode,
    int? geofenceId,
    @Default(true) bool allowSpectators,
    @Default(true) bool isPublic,
  }) = _CreateChallengeRequest;

  factory CreateChallengeRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateChallengeRequestFromJson(json);
}

@freezed
class ChallengeMessageModel with _$ChallengeMessageModel {
  const factory ChallengeMessageModel({
    required int id,
    required int challengeId,
    required int senderId,
    required String senderEmail,
    required String senderName,
    String? senderAvatarUrl,
    required String message,
    required DateTime sentAt,
  }) = _ChallengeMessageModel;

  factory ChallengeMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeMessageModelFromJson(json);
}

@freezed
class SendMessageRequest with _$SendMessageRequest {
  const factory SendMessageRequest({
    required String message,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
}
