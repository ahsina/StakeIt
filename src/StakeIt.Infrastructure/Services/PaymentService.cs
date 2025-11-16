using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Stripe;

namespace StakeIt.Infrastructure.Services;

public class PaymentService : IPaymentService
{
    private readonly ILogger<PaymentService> _logger;
    private readonly string _secretKey;
    private readonly decimal _platformCommissionRate;

    public PaymentService(IConfiguration configuration, ILogger<PaymentService> logger)
    {
        _logger = logger;
        _secretKey = configuration["Stripe:SecretKey"]
            ?? throw new InvalidOperationException("Stripe SecretKey not configured");
        _platformCommissionRate = decimal.Parse(configuration["AppSettings:PlatformCommissionRate"] ?? "0.10");

        StripeConfiguration.ApiKey = _secretKey;
    }

    public async Task<(bool Success, string? ErrorMessage, string? PaymentIntentId)> PreAuthorizePaymentAsync(
        int userId,
        decimal amount,
        string description)
    {
        try
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)(amount * 100), // Convert to cents
                Currency = "eur",
                CaptureMethod = "manual", // Pre-authorization (don't charge immediately)
                Description = description,
                Metadata = new Dictionary<string, string>
                {
                    { "userId", userId.ToString() },
                    { "type", "stake_preauth" }
                }
            };

            var service = new PaymentIntentService();
            var paymentIntent = await service.CreateAsync(options);

            _logger.LogInformation("Payment pre-authorized: {PaymentIntentId} for user {UserId}, amount {Amount}",
                paymentIntent.Id, userId, amount);

            return (true, null, paymentIntent.Id);
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Stripe error during pre-authorization for user {UserId}", userId);
            return (false, $"Payment error: {ex.Message}", null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during pre-authorization for user {UserId}", userId);
            return (false, "An error occurred while processing payment", null);
        }
    }

    public async Task<(bool Success, string? ErrorMessage)> CapturePaymentAsync(string paymentIntentId)
    {
        try
        {
            var service = new PaymentIntentService();
            var paymentIntent = await service.CaptureAsync(paymentIntentId);

            _logger.LogInformation("Payment captured: {PaymentIntentId}", paymentIntentId);

            return (true, null);
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Stripe error during payment capture for {PaymentIntentId}", paymentIntentId);
            return (false, $"Payment capture error: {ex.Message}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during payment capture for {PaymentIntentId}", paymentIntentId);
            return (false, "An error occurred while capturing payment");
        }
    }

    public async Task<(bool Success, string? ErrorMessage)> CancelPaymentAsync(string paymentIntentId)
    {
        try
        {
            var service = new PaymentIntentService();
            var paymentIntent = await service.CancelAsync(paymentIntentId);

            _logger.LogInformation("Payment cancelled: {PaymentIntentId}", paymentIntentId);

            return (true, null);
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Stripe error during payment cancellation for {PaymentIntentId}", paymentIntentId);
            return (false, $"Payment cancellation error: {ex.Message}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during payment cancellation for {PaymentIntentId}", paymentIntentId);
            return (false, "An error occurred while cancelling payment");
        }
    }

    public async Task<(bool Success, string? ErrorMessage)> TransferToUserAsync(
        int fromUserId,
        int toUserId,
        decimal amount,
        string description)
    {
        try
        {
            // Calculate amounts after commission
            var commissionAmount = amount * _platformCommissionRate;
            var transferAmount = amount - commissionAmount;

            // In production, this would use Stripe Connect to transfer to the user's connected account
            // For now, we'll just log it
            _logger.LogInformation(
                "Transfer initiated: {Amount}€ from user {FromUserId} to user {ToUserId} (commission: {Commission}€)",
                transferAmount, fromUserId, toUserId, commissionAmount);

            // TODO: Implement actual Stripe Connect transfer
            // var transferOptions = new TransferCreateOptions
            // {
            //     Amount = (long)(transferAmount * 100),
            //     Currency = "eur",
            //     Destination = recipientStripeAccountId,
            //     Description = description
            // };

            return (true, null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during transfer from {FromUserId} to {ToUserId}", fromUserId, toUserId);
            return (false, "An error occurred while processing transfer");
        }
    }

    public async Task<(bool Success, string? ErrorMessage)> TransferToCharityAsync(
        int userId,
        string charityId,
        decimal amount)
    {
        try
        {
            // Calculate amount after commission
            var commissionAmount = amount * _platformCommissionRate;
            var transferAmount = amount - commissionAmount;

            _logger.LogInformation(
                "Charity transfer initiated: {Amount}€ from user {UserId} to charity {CharityId} (commission: {Commission}€)",
                transferAmount, userId, charityId, commissionAmount);

            // TODO: Implement charity transfer
            // This would transfer to the charity's Stripe Connect account

            return (true, null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during charity transfer from user {UserId} to {CharityId}", userId, charityId);
            return (false, "An error occurred while processing charity transfer");
        }
    }

    public async Task<(bool Success, string? ErrorMessage, string? CustomerId)> CreateCustomerAsync(
        int userId,
        string email,
        string? name = null)
    {
        try
        {
            var options = new CustomerCreateOptions
            {
                Email = email,
                Name = name,
                Metadata = new Dictionary<string, string>
                {
                    { "userId", userId.ToString() }
                }
            };

            var service = new CustomerService();
            var customer = await service.CreateAsync(options);

            _logger.LogInformation("Stripe customer created: {CustomerId} for user {UserId}", customer.Id, userId);

            return (true, null, customer.Id);
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Stripe error creating customer for user {UserId}", userId);
            return (false, $"Error creating customer: {ex.Message}", null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating customer for user {UserId}", userId);
            return (false, "An error occurred while creating customer", null);
        }
    }

    public async Task<(bool Success, string? ErrorMessage)> AddPaymentMethodAsync(
        string customerId,
        string paymentMethodId)
    {
        try
        {
            // Attach payment method to customer
            var attachOptions = new PaymentMethodAttachOptions
            {
                Customer = customerId
            };

            var paymentMethodService = new PaymentMethodService();
            await paymentMethodService.AttachAsync(paymentMethodId, attachOptions);

            // Set as default payment method
            var customerOptions = new CustomerUpdateOptions
            {
                InvoiceSettings = new CustomerInvoiceSettingsOptions
                {
                    DefaultPaymentMethod = paymentMethodId
                }
            };

            var customerService = new CustomerService();
            await customerService.UpdateAsync(customerId, customerOptions);

            _logger.LogInformation("Payment method {PaymentMethodId} added to customer {CustomerId}",
                paymentMethodId, customerId);

            return (true, null);
        }
        catch (StripeException ex)
        {
            _logger.LogError(ex, "Stripe error adding payment method {PaymentMethodId} to customer {CustomerId}",
                paymentMethodId, customerId);
            return (false, $"Error adding payment method: {ex.Message}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding payment method {PaymentMethodId} to customer {CustomerId}",
                paymentMethodId, customerId);
            return (false, "An error occurred while adding payment method");
        }
    }
}
