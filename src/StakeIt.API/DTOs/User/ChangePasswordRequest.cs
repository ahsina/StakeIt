using System.ComponentModel.DataAnnotations;

namespace StakeIt.API.DTOs.User;

public class ChangePasswordRequest
{
    [Required]
    public required string CurrentPassword { get; set; }

    [Required]
    [MinLength(8)]
    public required string NewPassword { get; set; }
}
