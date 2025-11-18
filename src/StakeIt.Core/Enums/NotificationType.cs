namespace StakeIt.Core.Enums;

public enum NotificationType
{
    // Stake related
    StakeCreated,
    StakeCompleted,
    StakeFailed,
    StakeExpiringSoon,
    StakeCancelled,
    ProofRequired,
    ProofValidated,
    ProofRejected,

    // Challenge related
    ChallengeInvite,
    ChallengeStarted,
    ChallengeCompleted,
    ChallengeLost,
    NewChallengeAvailable,

    // Daily challenges
    DailyChallengeAvailable,
    DailyChallengeCompleted,
    DailyChallengeExpiring,

    // Social
    FriendRequest,
    FriendAccepted,
    FriendChallengeYou,
    MessageReceived,

    // Gamification
    LevelUp,
    BadgeEarned,
    StreakAchieved,
    StreakLost,
    LeaderboardRankChanged,

    // Financial
    PaymentAuthorized,
    PaymentCaptured,
    PaymentRefunded,
    BonusEarned,

    // System
    AccountVerified,
    PasswordChanged,
    SecurityAlert,
    SystemMaintenance,
    FeatureAnnouncement
}
