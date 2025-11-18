using System.ComponentModel.DataAnnotations;

namespace StakeIt.API.DTOs.Auth;

public class TokenRequest
{
    [Required]
    public required string Token { get; set; }
}
