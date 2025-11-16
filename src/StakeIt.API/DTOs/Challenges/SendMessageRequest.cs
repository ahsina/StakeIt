using System.ComponentModel.DataAnnotations;

namespace StakeIt.API.DTOs.Challenges;

public class SendMessageRequest
{
    [Required]
    [StringLength(1000, MinimumLength = 1)]
    public required string Message { get; set; }
}
