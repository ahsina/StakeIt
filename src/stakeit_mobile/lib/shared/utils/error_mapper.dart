import 'package:dio/dio.dart';

class ErrorMapper {
  ErrorMapper._();

  /// Map any error to user-friendly message
  static String mapError(dynamic error) {
    if (error is DioException) {
      return _mapDioError(error);
    } else if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return 'Une erreur inattendue s\'est produite';
    }
  }

  /// Map DioException to user-friendly message
  static String _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Délai de connexion dépassé. Veuillez réessayer.';

      case DioExceptionType.sendTimeout:
        return 'Délai d\'envoi dépassé. Veuillez réessayer.';

      case DioExceptionType.receiveTimeout:
        return 'Délai de réception dépassé. Veuillez réessayer.';

      case DioExceptionType.badCertificate:
        return 'Certificat de sécurité invalide.';

      case DioExceptionType.badResponse:
        return _mapBadResponse(error);

      case DioExceptionType.cancel:
        return 'Requête annulée.';

      case DioExceptionType.connectionError:
        return 'Erreur de connexion. Vérifiez votre connexion internet.';

      case DioExceptionType.unknown:
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }
  }

  /// Map bad response based on status code
  static String _mapBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Try to extract error message from response
    String? message;
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          data['title'] as String?;
    }

    // If we have a specific message from the API, use it
    if (message != null && message.isNotEmpty) {
      return message;
    }

    // Otherwise, map based on status code
    switch (statusCode) {
      case 400:
        return 'Requête invalide. Veuillez vérifier les informations saisies.';
      case 401:
        return 'Session expirée. Veuillez vous reconnecter.';
      case 403:
        return 'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
      case 404:
        return 'Ressource introuvable.';
      case 409:
        return 'Conflit. Cette opération ne peut pas être effectuée.';
      case 422:
        return 'Données invalides. Veuillez vérifier les informations saisies.';
      case 429:
        return 'Trop de requêtes. Veuillez réessayer dans quelques instants.';
      case 500:
        return 'Erreur serveur. Veuillez réessayer plus tard.';
      case 502:
        return 'Service temporairement indisponible. Veuillez réessayer.';
      case 503:
        return 'Service en maintenance. Veuillez réessayer plus tard.';
      default:
        return 'Une erreur s\'est produite. Veuillez réessayer.';
    }
  }

  /// Map authentication errors
  static String mapAuthError(dynamic error) {
    final message = mapError(error);

    // Common authentication error patterns
    if (message.toLowerCase().contains('invalid credentials') ||
        message.toLowerCase().contains('incorrect password')) {
      return 'Email ou mot de passe incorrect.';
    }

    if (message.toLowerCase().contains('user not found') ||
        message.toLowerCase().contains('compte introuvable')) {
      return 'Aucun compte n\'existe avec cet email.';
    }

    if (message.toLowerCase().contains('email already exists') ||
        message.toLowerCase().contains('email déjà utilisé')) {
      return 'Un compte existe déjà avec cet email.';
    }

    if (message.toLowerCase().contains('account disabled')) {
      return 'Votre compte a été désactivé. Contactez le support.';
    }

    if (message.toLowerCase().contains('email not verified')) {
      return 'Veuillez vérifier votre email avant de vous connecter.';
    }

    return message;
  }

  /// Map payment errors
  static String mapPaymentError(dynamic error) {
    final message = mapError(error);

    // Common payment error patterns
    if (message.toLowerCase().contains('insufficient funds') ||
        message.toLowerCase().contains('solde insuffisant')) {
      return 'Solde insuffisant pour effectuer cette opération.';
    }

    if (message.toLowerCase().contains('card declined') ||
        message.toLowerCase().contains('carte refusée')) {
      return 'Votre carte a été refusée. Veuillez utiliser une autre carte.';
    }

    if (message.toLowerCase().contains('card expired')) {
      return 'Votre carte a expiré. Veuillez ajouter une nouvelle carte.';
    }

    if (message.toLowerCase().contains('invalid card')) {
      return 'Carte invalide. Veuillez vérifier les informations.';
    }

    if (message.toLowerCase().contains('payment failed')) {
      return 'Le paiement a échoué. Veuillez réessayer.';
    }

    if (message.toLowerCase().contains('minimum amount') ||
        message.toLowerCase().contains('montant minimum')) {
      return 'Le montant minimum requis n\'est pas atteint.';
    }

    return message;
  }

  /// Map stake errors
  static String mapStakeError(dynamic error) {
    final message = mapError(error);

    if (message.toLowerCase().contains('already has active stake')) {
      return 'Vous avez déjà un stake actif pour cet objectif.';
    }

    if (message.toLowerCase().contains('cannot cancel')) {
      return 'Ce stake ne peut pas être annulé.';
    }

    if (message.toLowerCase().contains('proof already submitted')) {
      return 'Une preuve a déjà été soumise pour cette période.';
    }

    if (message.toLowerCase().contains('outside allowed area')) {
      return 'Vous devez être dans la zone autorisée pour soumettre une preuve.';
    }

    return message;
  }

  /// Map challenge errors
  static String mapChallengeError(dynamic error) {
    final message = mapError(error);

    if (message.toLowerCase().contains('already joined')) {
      return 'Vous avez déjà rejoint ce défi.';
    }

    if (message.toLowerCase().contains('challenge full')) {
      return 'Ce défi est complet. Nombre maximum de participants atteint.';
    }

    if (message.toLowerCase().contains('challenge started')) {
      return 'Ce défi a déjà commencé. Vous ne pouvez plus le rejoindre.';
    }

    if (message.toLowerCase().contains('not a participant')) {
      return 'Vous ne participez pas à ce défi.';
    }

    return message;
  }

  /// Map location errors
  static String mapLocationError(dynamic error) {
    final message = error.toString();

    if (message.contains('Location services are disabled')) {
      return 'Les services de localisation sont désactivés. Veuillez les activer dans les paramètres.';
    }

    if (message.contains('Location permission denied')) {
      return 'Permission de localisation refusée. Veuillez l\'autoriser dans les paramètres.';
    }

    if (message.contains('Location permission permanently denied')) {
      return 'Permission de localisation définitivement refusée. Veuillez l\'autoriser dans les paramètres de l\'appareil.';
    }

    if (message.contains('timeout')) {
      return 'Délai de localisation dépassé. Veuillez réessayer.';
    }

    return 'Impossible d\'obtenir votre localisation. Veuillez réessayer.';
  }

  /// Map image errors
  static String mapImageError(dynamic error) {
    final message = error.toString();

    if (message.contains('Camera permission denied')) {
      return 'Permission de caméra refusée. Veuillez l\'autoriser dans les paramètres.';
    }

    if (message.contains('Gallery permission denied')) {
      return 'Permission de galerie refusée. Veuillez l\'autoriser dans les paramètres.';
    }

    if (message.contains('No image selected')) {
      return 'Aucune image sélectionnée.';
    }

    if (message.contains('Image too large')) {
      return 'L\'image est trop grande. Taille maximum: 5 MB.';
    }

    if (message.contains('Image processing failed')) {
      return 'Erreur lors du traitement de l\'image. Veuillez réessayer.';
    }

    return 'Erreur lors de la sélection de l\'image. Veuillez réessayer.';
  }

  /// Get error title based on error type
  static String getErrorTitle(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      switch (statusCode) {
        case 401:
          return 'Non autorisé';
        case 403:
          return 'Accès refusé';
        case 404:
          return 'Introuvable';
        case 500:
        case 502:
        case 503:
          return 'Erreur serveur';
        default:
          return 'Erreur';
      }
    }
    return 'Erreur';
  }

  /// Check if error is a network error
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.unknown;
    }
    return false;
  }

  /// Check if error is an authentication error
  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }
    return false;
  }

  /// Check if error requires retry
  static bool shouldRetry(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          statusCode == 408 || // Request Timeout
          statusCode == 429 || // Too Many Requests
          statusCode == 500 || // Internal Server Error
          statusCode == 502 || // Bad Gateway
          statusCode == 503 || // Service Unavailable
          statusCode == 504; // Gateway Timeout
    }
    return false;
  }
}
