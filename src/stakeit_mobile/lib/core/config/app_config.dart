class AppConfig {
  static const String appName = 'StakeIt';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:5000'; // Change for production
  static const String apiPrefix = '/api';

  // API Endpoints
  static const String authEndpoint = '$apiPrefix/auth';
  static const String usersEndpoint = '$apiPrefix/users';
  static const String stakesEndpoint = '$apiPrefix/stakes';
  static const String challengesEndpoint = '$apiPrefix/challenges';
  static const String geofencesEndpoint = '$apiPrefix/geofences';

  // SignalR Hub
  static const String challengeHubUrl = '$baseUrl/hubs/challenge';

  // Stripe
  static const String stripePublishableKey = 'pk_test_...'; // Add your key

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Location
  static const double defaultLatitude = 49.6116;
  static const double defaultLongitude = 6.1319; // Luxembourg

  // Validation
  static const double minStakeAmount = 5.00;
  static const double maxStakeAmount = 500.00;
  static const int passwordMinLength = 8;
}
