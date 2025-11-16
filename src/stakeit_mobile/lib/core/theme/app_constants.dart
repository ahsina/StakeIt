import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7FE8);
  static const Color primaryDark = Color(0xFF5446C6);

  // Secondary Colors
  static const Color secondary = Color(0xFF00B894);
  static const Color secondaryLight = Color(0xFF33C9A7);
  static const Color secondaryDark = Color(0xFF009975);

  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFD63031);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF0984E3);

  // Stake Status Colors
  static const Color stakeActive = Color(0xFF00B894);
  static const Color stakeCompleted = Color(0xFF0984E3);
  static const Color stakeFailed = Color(0xFFD63031);
  static const Color stakeCancelled = Color(0xFF636E72);

  // Challenge Status Colors
  static const Color challengeOpen = Color(0xFFFDCB6E);
  static const Color challengeActive = Color(0xFF00B894);
  static const Color challengeCompleted = Color(0xFF0984E3);
  static const Color challengeCancelled = Color(0xFF636E72);

  // Category Colors
  static const Color categoryFitness = Color(0xFFE74C3C);
  static const Color categoryEducation = Color(0xFF3498DB);
  static const Color categoryProductivity = Color(0xFF9B59B6);
  static const Color categoryFinance = Color(0xFF27AE60);
  static const Color categoryPersonalDevelopment = Color(0xFFE67E22);
  static const Color categoryFamily = Color(0xFFE91E63);
  static const Color categoryCreativity = Color(0xFF673AB7);
  static const Color categoryHome = Color(0xFF795548);
  static const Color categoryDigitalDetox = Color(0xFF009688);

  // Neutral Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textDisabled = Color(0xFFB2BEC3);

  static const Color backgroundLight = Color(0xFFFDFEFE);
  static const Color backgroundDark = Color(0xFFF5F6FA);

  static const Color divider = Color(0xFFDFE6E9);
  static const Color border = Color(0xFFB2BEC3);

  // Gradient Colors
  static final List<Color> primaryGradient = [primary, primaryLight];
  static final List<Color> successGradient = [success, secondaryLight];
  static final List<Color> errorGradient = [error, Color(0xFFFF6B6B)];

  // Medal Colors
  static const Color medalGold = Color(0xFFFFD700);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalBronze = Color(0xFFCD7F32);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF6C5CE7),
    Color(0xFF00B894),
    Color(0xFFE74C3C),
    Color(0xFF3498DB),
    Color(0xFFE67E22),
    Color(0xFF9B59B6),
    Color(0xFFF39C12),
    Color(0xFF1ABC9C),
  ];
}

class AppSizes {
  // Padding & Margin
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusRound = 100.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Button Heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;

  // Card Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  // Avatar Sizes
  static const double avatarS = 32.0;
  static const double avatarM = 48.0;
  static const double avatarL = 64.0;
  static const double avatarXL = 100.0;
}

class AppTextStyles {
  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // Headings
  static const TextStyle headingLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  // Button
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

class AppAnimations {
  // Duration
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
}

class AppConstants {
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Stake Constraints
  static const double minStakeAmount = 5.0;
  static const double maxStakeAmount = 500.0;
  static const int minStakeProofs = 1;
  static const int maxStakeProofs = 100;

  // Challenge Constraints
  static const int minChallengeParticipants = 2;
  static const int maxChallengeParticipants = 100;
  static const double minChallengeEntryFee = 5.0;
  static const double maxChallengeEntryFee = 500.0;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Images
  static const int maxImageSizeMB = 5;
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;

  // GPS
  static const double defaultGeofenceRadius = 100.0; // meters
  static const Duration gpsTimeout = Duration(seconds: 10);

  // Messages
  static const int maxMessageLength = 500;
  static const int minMessageLength = 1;

  // Wallet
  static const double minPayoutAmount = 10.0;
  static const double maxPayoutAmount = 10000.0;
}
