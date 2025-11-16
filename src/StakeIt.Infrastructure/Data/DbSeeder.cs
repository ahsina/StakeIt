using StakeIt.Core.Entities;

namespace StakeIt.Infrastructure.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(StakeItDbContext context)
    {
        // Seed Badges
        if (!context.Badges.Any())
        {
            var badges = new List<Badge>
            {
                // Achievement Badges
                new Badge
                {
                    Name = "First Step",
                    Description = "Complète ton premier stake",
                    Category = "Achievement",
                    Rarity = "Common",
                    XPReward = 50,
                    IconUrl = "/badges/first-step.png"
                },
                new Badge
                {
                    Name = "Dedicated",
                    Description = "Complète 10 stakes",
                    Category = "Achievement",
                    Rarity = "Common",
                    XPReward = 100,
                    IconUrl = "/badges/dedicated.png"
                },
                new Badge
                {
                    Name = "Champion",
                    Description = "Complète 50 stakes",
                    Category = "Achievement",
                    Rarity = "Rare",
                    XPReward = 500,
                    IconUrl = "/badges/champion.png"
                },
                new Badge
                {
                    Name = "Legend",
                    Description = "Complète 100 stakes",
                    Category = "Achievement",
                    Rarity = "Epic",
                    XPReward = 1000,
                    IconUrl = "/badges/legend.png"
                },

                // Streak Badges
                new Badge
                {
                    Name = "On Fire",
                    Description = "Gagne 5 stakes consécutifs",
                    Category = "Streak",
                    Rarity = "Rare",
                    XPReward = 200,
                    IconUrl = "/badges/on-fire.png"
                },
                new Badge
                {
                    Name = "Unstoppable",
                    Description = "Gagne 10 stakes consécutifs",
                    Category = "Streak",
                    Rarity = "Epic",
                    XPReward = 500,
                    IconUrl = "/badges/unstoppable.png"
                },
                new Badge
                {
                    Name = "Invincible",
                    Description = "Gagne 20 stakes consécutifs",
                    Category = "Streak",
                    Rarity = "Legendary",
                    XPReward = 1500,
                    IconUrl = "/badges/invincible.png"
                },
                new Badge
                {
                    Name = "Week Warrior",
                    Description = "7 jours de streak",
                    Category = "Streak",
                    Rarity = "Common",
                    XPReward = 150,
                    IconUrl = "/badges/week-warrior.png"
                },
                new Badge
                {
                    Name = "Month Master",
                    Description = "30 jours de streak",
                    Category = "Streak",
                    Rarity = "Epic",
                    XPReward = 1000,
                    IconUrl = "/badges/month-master.png"
                },

                // Challenge Badges
                new Badge
                {
                    Name = "First Blood",
                    Description = "Gagne ton premier duel",
                    Category = "Challenge",
                    Rarity = "Common",
                    XPReward = 100,
                    IconUrl = "/badges/first-blood.png"
                },
                new Badge
                {
                    Name = "Duelist",
                    Description = "Gagne 10 duels",
                    Category = "Challenge",
                    Rarity = "Rare",
                    XPReward = 300,
                    IconUrl = "/badges/duelist.png"
                },
                new Badge
                {
                    Name = "Team Player",
                    Description = "Gagne 5 team battles",
                    Category = "Challenge",
                    Rarity = "Rare",
                    XPReward = 400,
                    IconUrl = "/badges/team-player.png"
                },
                new Badge
                {
                    Name = "Podium",
                    Description = "Top 3 dans une league",
                    Category = "Challenge",
                    Rarity = "Epic",
                    XPReward = 600,
                    IconUrl = "/badges/podium.png"
                },

                // Financial Badges
                new Badge
                {
                    Name = "Money Saver",
                    Description = "Économise 100€",
                    Category = "Financial",
                    Rarity = "Common",
                    XPReward = 100,
                    IconUrl = "/badges/money-saver.png"
                },
                new Badge
                {
                    Name = "Profit Maker",
                    Description = "Net profit +500€",
                    Category = "Financial",
                    Rarity = "Epic",
                    XPReward = 500,
                    IconUrl = "/badges/profit-maker.png"
                },
                new Badge
                {
                    Name = "High Roller",
                    Description = "Mise 100€+ sur un stake",
                    Category = "Financial",
                    Rarity = "Rare",
                    XPReward = 200,
                    IconUrl = "/badges/high-roller.png"
                },

                // Social Badges
                new Badge
                {
                    Name = "Friendly",
                    Description = "Avoir 10 amis",
                    Category = "Social",
                    Rarity = "Common",
                    XPReward = 50,
                    IconUrl = "/badges/friendly.png"
                },
                new Badge
                {
                    Name = "Influencer",
                    Description = "5 amis invités actifs",
                    Category = "Social",
                    Rarity = "Rare",
                    XPReward = 300,
                    IconUrl = "/badges/influencer.png"
                },
                new Badge
                {
                    Name = "Trash Talker",
                    Description = "Envoyer 100 messages en challenges",
                    Category = "Social",
                    Rarity = "Common",
                    XPReward = 100,
                    IconUrl = "/badges/trash-talker.png"
                },

                // Special Badges
                new Badge
                {
                    Name = "Perfectionist",
                    Description = "100% win rate sur 20+ stakes",
                    Category = "Achievement",
                    Rarity = "Legendary",
                    XPReward = 2000,
                    IconUrl = "/badges/perfectionist.png"
                }
            };

            context.Badges.AddRange(badges);
            await context.SaveChangesAsync();
        }

        // Seed Geofences Publiques (Luxembourg)
        if (!context.Geofences.Any())
        {
            var geofences = new List<Geofence>
            {
                // Gyms Luxembourg
                new Geofence
                {
                    Name = "Basic Fit Luxembourg-Ville",
                    Category = "Gym",
                    Latitude = 49.6116m,
                    Longitude = 6.1319m,
                    RadiusMeters = 100,
                    Address = "5 Rue Alphonse Weicker",
                    City = "Luxembourg",
                    Country = "LU",
                    IsPublic = true
                },
                new Geofence
                {
                    Name = "Fitness Zone Kirchberg",
                    Category = "Gym",
                    Latitude = 49.6265m,
                    Longitude = 6.1541m,
                    RadiusMeters = 100,
                    Address = "2 Rue Alphonse Weicker",
                    City = "Luxembourg",
                    Country = "LU",
                    IsPublic = true
                },
                new Geofence
                {
                    Name = "CrossFit Luxembourg",
                    Category = "Gym",
                    Latitude = 49.6033m,
                    Longitude = 6.1296m,
                    RadiusMeters = 100,
                    Address = "7 Rue de la Boucherie",
                    City = "Luxembourg",
                    Country = "LU",
                    IsPublic = true
                },

                // Libraries
                new Geofence
                {
                    Name = "Bibliothèque Nationale Luxembourg",
                    Category = "Library",
                    Latitude = 49.6251m,
                    Longitude = 6.1522m,
                    RadiusMeters = 150,
                    Address = "37E Avenue John F. Kennedy",
                    City = "Luxembourg",
                    Country = "LU",
                    IsPublic = true
                },

                // Parks (for running/walking)
                new Geofence
                {
                    Name = "Parc de la Pétrusse",
                    Category = "Park",
                    Latitude = 49.6083m,
                    Longitude = 6.1258m,
                    RadiusMeters = 300,
                    Address = "Parc de la Pétrusse",
                    City = "Luxembourg",
                    Country = "LU",
                    IsPublic = true
                },
                new Geofence
                {
                    Name = "Parc Municipal Luxembourg",
                    Category = "Park",
                    Latitude = 49.6147m,
                    Longitude = 6.1331m,
                    RadiusMeters = 250,
                    Address = "Parc Municipal",
                    City = "Luxembourg",
                    Country = "LU",
                    IsPublic = true
                }
            };

            context.Geofences.AddRange(geofences);
            await context.SaveChangesAsync();
        }
    }
}
