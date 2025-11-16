using Microsoft.EntityFrameworkCore;
using StakeIt.Core.Entities;

namespace StakeIt.Infrastructure.Data;

public class StakeItDbContext : DbContext
{
    public StakeItDbContext(DbContextOptions<StakeItDbContext> options) : base(options)
    {
    }

    // Users & Auth
    public DbSet<User> Users { get; set; }
    public DbSet<Friendship> Friendships { get; set; }

    // Stakes
    public DbSet<Stake> Stakes { get; set; }
    public DbSet<StakeProof> StakeProofs { get; set; }
    public DbSet<Geofence> Geofences { get; set; }

    // Challenges
    public DbSet<Challenge> Challenges { get; set; }
    public DbSet<ChallengeParticipant> ChallengeParticipants { get; set; }
    public DbSet<ChallengeProof> ChallengeProofs { get; set; }
    public DbSet<ChallengeMessage> ChallengeMessages { get; set; }
    public DbSet<ChallengeSpectator> ChallengeSpectators { get; set; }

    // Gamification
    public DbSet<Badge> Badges { get; set; }

    // Financial
    public DbSet<Transaction> Transactions { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply all configurations from this assembly
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(StakeItDbContext).Assembly);

        // Configure User entity
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
            entity.Property(e => e.PasswordHash).IsRequired();
            entity.Property(e => e.FirstName).HasMaxLength(100);
            entity.Property(e => e.LastName).HasMaxLength(100);
            entity.Property(e => e.Country).HasMaxLength(2);
            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.AccountStatus).HasMaxLength(20).HasDefaultValue("Active");
            entity.Property(e => e.CurrentLevel).HasDefaultValue(1);
            entity.Property(e => e.TotalXP).HasDefaultValue(0);
            entity.Property(e => e.CurrentStreak).HasDefaultValue(0);
            entity.Property(e => e.LongestStreak).HasDefaultValue(0);

            // Many-to-many relationship with Badges
            entity.HasMany(e => e.Badges)
                .WithMany(e => e.Users)
                .UsingEntity(j => j.ToTable("UserBadges"));
        });

        // Configure Stake entity
        modelBuilder.Entity<Stake>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.AmountEUR).HasPrecision(10, 2);
            entity.Property(e => e.Status).HasConversion<string>();
            entity.Property(e => e.Category).HasConversion<string>();
            entity.Property(e => e.ProofMode).HasConversion<string>();
            entity.Property(e => e.FailureMode).HasConversion<string>();
            entity.Property(e => e.PaymentStatus).HasConversion<string>();

            entity.HasOne(e => e.User)
                .WithMany(e => e.Stakes)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.Geofence)
                .WithMany(e => e.Stakes)
                .HasForeignKey(e => e.GeofenceId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasMany(e => e.Proofs)
                .WithOne(e => e.Stake)
                .HasForeignKey(e => e.StakeId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure StakeProof entity
        modelBuilder.Entity<StakeProof>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.ProofType).HasConversion<string>();
            entity.Property(e => e.ValidationStatus).HasConversion<string>();
            entity.Property(e => e.Latitude).HasPrecision(9, 6);
            entity.Property(e => e.Longitude).HasPrecision(9, 6);
            entity.Property(e => e.AIConfidenceScore).HasPrecision(3, 2);

            entity.HasOne(e => e.ValidatedByUser)
                .WithMany()
                .HasForeignKey(e => e.ValidatedBy)
                .OnDelete(DeleteBehavior.SetNull);
        });

        // Configure Geofence entity
        modelBuilder.Entity<Geofence>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Category).HasMaxLength(50);
            entity.Property(e => e.Latitude).HasPrecision(9, 6);
            entity.Property(e => e.Longitude).HasPrecision(9, 6);
            entity.Property(e => e.Address).HasMaxLength(500);
            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.Country).HasMaxLength(2);
            entity.Property(e => e.IsPublic).HasDefaultValue(true);

            entity.HasOne(e => e.CreatedByUser)
                .WithMany()
                .HasForeignKey(e => e.CreatedByUserId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        // Configure Challenge entity
        modelBuilder.Entity<Challenge>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.Objective).HasMaxLength(500);
            entity.Property(e => e.Type).HasConversion<string>();
            entity.Property(e => e.Status).HasConversion<string>();
            entity.Property(e => e.ScoringMethod).HasMaxLength(50);

            entity.HasOne(e => e.Creator)
                .WithMany()
                .HasForeignKey(e => e.CreatorUserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.Winner)
                .WithMany()
                .HasForeignKey(e => e.WinnerUserId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        // Configure ChallengeParticipant entity
        modelBuilder.Entity<ChallengeParticipant>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.StakeAmount).HasPrecision(10, 2);
            entity.Property(e => e.WinAmount).HasPrecision(10, 2);
            entity.Property(e => e.PaymentStatus).HasConversion<string>();
            entity.Property(e => e.PayoutStatus).HasMaxLength(20);

            entity.HasOne(e => e.Challenge)
                .WithMany(e => e.Participants)
                .HasForeignKey(e => e.ChallengeId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.User)
                .WithMany(e => e.ChallengeParticipations)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Unique constraint: un user ne peut participer qu'une fois à un challenge
            entity.HasIndex(e => new { e.ChallengeId, e.UserId }).IsUnique();
        });

        // Configure ChallengeProof entity
        modelBuilder.Entity<ChallengeProof>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.ProofType).HasConversion<string>();
            entity.Property(e => e.ValidationStatus).HasConversion<string>();
            entity.Property(e => e.Latitude).HasPrecision(9, 6);
            entity.Property(e => e.Longitude).HasPrecision(9, 6);

            entity.HasOne(e => e.Challenge)
                .WithMany(e => e.Proofs)
                .HasForeignKey(e => e.ChallengeId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.Participant)
                .WithMany()
                .HasForeignKey(e => e.ParticipantId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Configure ChallengeMessage entity
        modelBuilder.Entity<ChallengeMessage>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.MessageType).HasMaxLength(20);
            entity.Property(e => e.MessageText).HasMaxLength(1000);
            entity.Property(e => e.GifUrl).HasMaxLength(500);

            entity.HasOne(e => e.Challenge)
                .WithMany(e => e.Messages)
                .HasForeignKey(e => e.ChallengeId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Configure ChallengeSpectator entity
        modelBuilder.Entity<ChallengeSpectator>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.BetAmount).HasPrecision(10, 2);
            entity.Property(e => e.BetOdds).HasPrecision(4, 2);
            entity.Property(e => e.BetPayout).HasPrecision(10, 2);

            entity.HasOne(e => e.Challenge)
                .WithMany(e => e.Spectators)
                .HasForeignKey(e => e.ChallengeId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.BetOnUser)
                .WithMany()
                .HasForeignKey(e => e.BetOnUserId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        // Configure Badge entity
        modelBuilder.Entity<Badge>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.IconUrl).HasMaxLength(500);
            entity.Property(e => e.Category).HasMaxLength(50);
            entity.Property(e => e.Rarity).HasMaxLength(20);
            entity.Property(e => e.XPReward).HasDefaultValue(0);
        });

        // Configure Friendship entity
        modelBuilder.Entity<Friendship>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Status).HasMaxLength(20).HasDefaultValue("Pending");

            entity.HasOne(e => e.UserA)
                .WithMany(e => e.FriendshipsInitiated)
                .HasForeignKey(e => e.UserAId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.UserB)
                .WithMany(e => e.FriendshipsReceived)
                .HasForeignKey(e => e.UserBId)
                .OnDelete(DeleteBehavior.Restrict);

            // Unique constraint: éviter les doublons de friendships
            entity.HasIndex(e => new { e.UserAId, e.UserBId }).IsUnique();
        });

        // Configure Transaction entity
        modelBuilder.Entity<Transaction>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Type).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Amount).HasPrecision(10, 2);
            entity.Property(e => e.Currency).HasMaxLength(3).HasDefaultValue("EUR");
            entity.Property(e => e.Status).HasMaxLength(20).HasDefaultValue("Pending");
            entity.Property(e => e.Description).HasMaxLength(500);

            entity.HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.Stake)
                .WithMany()
                .HasForeignKey(e => e.StakeId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(e => e.Challenge)
                .WithMany()
                .HasForeignKey(e => e.ChallengeId)
                .OnDelete(DeleteBehavior.SetNull);
        });
    }
}
