using System.ComponentModel.DataAnnotations;

namespace StakeIt.API.DTOs.Auth;

public class ResetPasswordRequest
{
    [Required]
    public required string Token { get; set; }

    [Required]
    [MinLength(8, ErrorMessage = "Password must be at least 8 characters long")]
    public required string NewPassword { get; set; }
}
