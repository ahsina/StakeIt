namespace StakeIt.Core.Enums;

public enum DailyChallengeType
{
    CreateStake,           // Create a new stake
    CompleteProof,         // Submit a proof for any stake
    LoginStreak,           // Maintain login streak
    InviteFriend,          // Invite a friend
    JoinChallenge,         // Join a multiplayer challenge
    ShareAchievement,      // Share an achievement on social media
    WatchMotivationalVideo, // Watch a motivational content
    CompleteProfile,       // Complete user profile
    AddPaymentMethod,      // Add a payment method
    SubscribePremium,      // Subscribe to premium
    CompleteStake,         // Complete any stake successfully
    CreateHighValueStake,  // Create a stake with amount > threshold
    UseGPSProof,          // Submit a GPS-based proof
    UsePhotoProof,        // Submit a photo proof
    Custom                // Custom challenge
}
