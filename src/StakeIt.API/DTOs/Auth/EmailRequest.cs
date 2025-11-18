using System.ComponentModel.DataAnnotations;

namespace StakeIt.API.DTOs.Auth;

public class EmailRequest
{
    [Required]
    [EmailAddress]
    public required string Email { get; set; }
}
