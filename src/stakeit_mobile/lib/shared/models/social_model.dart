import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_model.freezed.dart';
part 'social_model.g.dart';

// Friend Model
@freezed
class FriendModel with _$FriendModel {
  const factory FriendModel({
    required int id,
    required int userId,
    required String email,
    required String firstName,
    required String lastName,
    String? avatarUrl,
    required int currentLevel,
    required int totalXP,
    required int currentStreak,
    required DateTime friendsSince,
  }) = _FriendModel;

  factory FriendModel.fromJson(Map<String, dynamic> json) =>
      _$FriendModelFromJson(json);
}

extension FriendModelX on FriendModel {
  String get fullName => '$firstName $lastName';
}

// Friend Request Model
enum FriendRequestStatus {
  @JsonValue('Pending')
  pending,
  @JsonValue('Accepted')
  accepted,
  @JsonValue('Rejected')
  rejected,
}

@freezed
class FriendRequestModel with _$FriendRequestModel {
  const factory FriendRequestModel({
    required int id,
    required int senderId,
    required String senderEmail,
    required String senderFirstName,
    required String senderLastName,
    String? senderAvatarUrl,
    required int receiverId,
    required String receiverEmail,
    required String receiverFirstName,
    required String receiverLastName,
    String? receiverAvatarUrl,
    required FriendRequestStatus status,
    required DateTime createdAt,
    DateTime? respondedAt,
  }) = _FriendRequestModel;

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestModelFromJson(json);
}

extension FriendRequestModelX on FriendRequestModel {
  String get senderFullName => '$senderFirstName $senderLastName';
  String get receiverFullName => '$receiverFirstName $receiverLastName';
}

// Social Feed Item Model
enum FeedItemType {
  @JsonValue('StakeCompleted')
  stakeCompleted,
  @JsonValue('StakeFailed')
  stakeFailed,
  @JsonValue('ChallengeWon')
  challengeWon,
  @JsonValue('ChallengeJoined')
  challengeJoined,
  @JsonValue('BadgeEarned')
  badgeEarned,
  @JsonValue('LevelUp')
  levelUp,
  @JsonValue('StreakMilestone')
  streakMilestone,
}

@freezed
class FeedItemModel with _$FeedItemModel {
  const factory FeedItemModel({
    required int id,
    required int userId,
    required String userEmail,
    required String userFirstName,
    required String userLastName,
    String? userAvatarUrl,
    required FeedItemType itemType,
    required String title,
    String? description,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
  }) = _FeedItemModel;

  factory FeedItemModel.fromJson(Map<String, dynamic> json) =>
      _$FeedItemModelFromJson(json);
}

extension FeedItemModelX on FeedItemModel {
  String get userFullName => '$userFirstName $userLastName';

  String get iconEmoji {
    switch (itemType) {
      case FeedItemType.stakeCompleted:
        return '✅';
      case FeedItemType.stakeFailed:
        return '❌';
      case FeedItemType.challengeWon:
        return '🏆';
      case FeedItemType.challengeJoined:
        return '🎯';
      case FeedItemType.badgeEarned:
        return '🏅';
      case FeedItemType.levelUp:
        return '⬆️';
      case FeedItemType.streakMilestone:
        return '🔥';
    }
  }
}

// Referral Model
@freezed
class ReferralModel with _$ReferralModel {
  const factory ReferralModel({
    required int id,
    required int referrerId,
    required String referrerEmail,
    required String referralCode,
    int? referredUserId,
    String? referredEmail,
    required bool isRedeemed,
    DateTime? redeemedAt,
    double? bonusEarned,
    required DateTime createdAt,
  }) = _ReferralModel;

  factory ReferralModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralModelFromJson(json);
}

// Referral Stats Model
@freezed
class ReferralStatsModel with _$ReferralStatsModel {
  const factory ReferralStatsModel({
    required String myReferralCode,
    required int totalReferrals,
    required int successfulReferrals,
    required double totalBonusEarned,
    required List<ReferralModel> recentReferrals,
  }) = _ReferralStatsModel;

  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralStatsModelFromJson(json);
}

// Request Models
@freezed
class SendFriendRequestRequest with _$SendFriendRequestRequest {
  const factory SendFriendRequestRequest({
    required String receiverEmail,
  }) = _SendFriendRequestRequest;

  factory SendFriendRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$SendFriendRequestRequestFromJson(json);
}

@freezed
class RespondToFriendRequestRequest with _$RespondToFriendRequestRequest {
  const factory RespondToFriendRequestRequest({
    required bool accept,
  }) = _RespondToFriendRequestRequest;

  factory RespondToFriendRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$RespondToFriendRequestRequestFromJson(json);
}
