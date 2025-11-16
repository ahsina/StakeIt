namespace StakeIt.Core.Enums;

public enum PaymentStatus
{
    PreAuthorized,    // Montant pré-autorisé (bloqué)
    Captured,         // Montant débité (échec)
    Refunded,         // Montant remboursé (succès)
    Failed            // Échec de paiement
}
