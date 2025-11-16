namespace StakeIt.Core.Enums;

public enum ProofMode
{
    GPS,              // Validation par géolocalisation
    Photo,            // Validation par photo avec timestamp
    Manual,           // Check-in manuel (honour system)
    AppIntegration    // Intégration app tierce (Strava, Apple Health, etc.)
}
