class Validators {
  Validators._();

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères';
    }

    return null;
  }

  /// Validate password with complexity requirements
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }

    if (value.length < minLength) {
      return '$fieldName doit contenir au moins $minLength caractères';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return '$fieldName ne peut pas dépasser $maxLength caractères';
    }

    return null;
  }

  /// Validate amount (positive number)
  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Le montant est requis';
    }

    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount == null) {
      return 'Veuillez entrer un montant valide';
    }

    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }

    if (min != null && amount < min) {
      return 'Le montant minimum est de ${min.toStringAsFixed(2)} €';
    }

    if (max != null && amount > max) {
      return 'Le montant maximum est de ${max.toStringAsFixed(2)} €';
    }

    return null;
  }

  /// Validate stake amount (min 5€, max 10000€)
  static String? validateStakeAmount(String? value) {
    return validateAmount(value, min: 5.0, max: 10000.0);
  }

  /// Validate payout amount (min 10€)
  static String? validatePayoutAmount(String? value, {double? maxBalance}) {
    final error = validateAmount(value, min: 10.0);
    if (error != null) return error;

    if (maxBalance != null) {
      final amount = double.parse(value!.replaceAll(',', '.'));
      if (amount > maxBalance) {
        return 'Solde insuffisant (${maxBalance.toStringAsFixed(2)} € disponible)';
      }
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }

    final phoneRegex = RegExp(r'^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'URL est requise';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Veuillez entrer une URL valide';
    }

    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est requis';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Veuillez entrer un nombre valide';
    }

    if (number <= 0) {
      return 'Le nombre doit être supérieur à 0';
    }

    return null;
  }

  /// Validate duration in days (1-365)
  static String? validateDuration(String? value) {
    final error = validatePositiveNumber(value);
    if (error != null) return error;

    final days = int.parse(value!);
    if (days > 365) {
      return 'La durée ne peut pas dépasser 365 jours';
    }

    return null;
  }

  /// Validate frequency (1-100)
  static String? validateFrequency(String? value) {
    final error = validatePositiveNumber(value);
    if (error != null) return error;

    final frequency = int.parse(value!);
    if (frequency > 100) {
      return 'La fréquence ne peut pas dépasser 100';
    }

    return null;
  }

  /// Validate date is in future
  static String? validateFutureDate(DateTime? date) {
    if (date == null) {
      return 'La date est requise';
    }

    if (date.isBefore(DateTime.now())) {
      return 'La date doit être dans le futur';
    }

    return null;
  }

  /// Validate date is in past
  static String? validatePastDate(DateTime? date) {
    if (date == null) {
      return 'La date est requise';
    }

    if (date.isAfter(DateTime.now())) {
      return 'La date doit être dans le passé';
    }

    return null;
  }

  /// Validate time is in future
  static String? validateFutureTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'L\'heure est requise';
    }

    if (dateTime.isBefore(DateTime.now())) {
      return 'L\'heure doit être dans le futur';
    }

    return null;
  }

  /// Validate username (alphanumeric and underscores, 3-20 chars)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom d\'utilisateur est requis';
    }

    if (value.length < 3) {
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
    }

    if (value.length > 20) {
      return 'Le nom d\'utilisateur ne peut pas dépasser 20 caractères';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Le nom d\'utilisateur ne peut contenir que des lettres, chiffres et underscores';
    }

    return null;
  }

  /// Combine multiple validators
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
