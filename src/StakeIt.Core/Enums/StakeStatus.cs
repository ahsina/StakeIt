namespace StakeIt.Core.Enums;

public enum StakeStatus
{
    Active,      // Stake en cours
    Completed,   // Objectif réussi
    Failed,      // Objectif raté
    Cancelled    // Annulé (dans les 2h)
}
