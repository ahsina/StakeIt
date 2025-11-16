namespace StakeIt.Infrastructure.Services;

public interface IPaymentService
{
    // Pre-authorization (hold funds)
    Task<(bool Success, string? ErrorMessage, string? PaymentIntentId)> PreAuthorizePaymentAsync(
        int userId,
        decimal amount,
        string description);

    // Capture payment (charge the card)
    Task<(bool Success, string? ErrorMessage)> CapturePaymentAsync(string paymentIntentId);

    // Cancel pre-authorization (release funds)
    Task<(bool Success, string? ErrorMessage)> CancelPaymentAsync(string paymentIntentId);

    // Transfer money to another user
    Task<(bool Success, string? ErrorMessage)> TransferToUserAsync(
        int fromUserId,
        int toUserId,
        decimal amount,
        string description);

    // Transfer to charity
    Task<(bool Success, string? ErrorMessage)> TransferToCharityAsync(
        int userId,
        string charityId,
        decimal amount);

    // Create Stripe customer
    Task<(bool Success, string? ErrorMessage, string? CustomerId)> CreateCustomerAsync(
        int userId,
        string email,
        string? name = null);

    // Add payment method
    Task<(bool Success, string? ErrorMessage)> AddPaymentMethodAsync(
        string customerId,
        string paymentMethodId);
}
