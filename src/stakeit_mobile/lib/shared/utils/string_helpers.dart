class StringHelpers {
  StringHelpers._();

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalize each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Get initials from name
  static String getInitials(String name, {int maxInitials = 2}) {
    if (name.isEmpty) return '';

    final parts = name.trim().split(' ');
    final initials = parts
        .take(maxInitials)
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .join('');

    return initials;
  }

  /// Format file size in human-readable format
  static String formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }

  /// Pluralize word based on count
  static String pluralize(int count, String singular, String plural) {
    return count <= 1 ? singular : plural;
  }

  /// Format number with spaces (e.g., "1 234 567")
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  /// Remove all whitespace
  static String removeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }

  /// Convert to slug (URL-friendly)
  static String toSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Check if string is email
  static bool isEmail(String text) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(text);
  }

  /// Check if string is URL
  static bool isUrl(String text) {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(text);
  }

  /// Check if string is numeric
  static bool isNumeric(String text) {
    return double.tryParse(text) != null;
  }

  /// Extract numbers from string
  static String extractNumbers(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Extract letters from string
  static String extractLetters(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  /// Mask sensitive data (e.g., email, phone)
  static String maskEmail(String email) {
    if (!isEmail(email)) return email;

    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    final visibleStart = username.substring(0, 2);
    final visibleEnd = username.substring(username.length - 1);
    return '$visibleStart***$visibleEnd@$domain';
  }

  /// Mask phone number
  static String maskPhone(String phone) {
    final cleaned = extractNumbers(phone);
    if (cleaned.length < 4) return phone;

    final visibleEnd = cleaned.substring(cleaned.length - 2);
    final masked = '*' * (cleaned.length - 2);
    return '$masked$visibleEnd';
  }

  /// Mask card number (show last 4 digits)
  static String maskCardNumber(String cardNumber) {
    final cleaned = extractNumbers(cardNumber);
    if (cleaned.length < 4) return cardNumber;

    final last4 = cleaned.substring(cleaned.length - 4);
    return '**** **** **** $last4';
  }

  /// Format card number with spaces (e.g., "1234 5678 9012 3456")
  static String formatCardNumber(String cardNumber) {
    final cleaned = extractNumbers(cardNumber);
    final chunks = <String>[];

    for (var i = 0; i < cleaned.length; i += 4) {
      final end = i + 4 < cleaned.length ? i + 4 : cleaned.length;
      chunks.add(cleaned.substring(i, end));
    }

    return chunks.join(' ');
  }

  /// Format phone number (French format)
  static String formatPhoneNumber(String phone) {
    final cleaned = extractNumbers(phone);
    if (cleaned.length != 10) return phone;

    return cleaned.replaceAllMapped(
      RegExp(r'(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})'),
      (match) => '${match[1]} ${match[2]} ${match[3]} ${match[4]} ${match[5]}',
    );
  }

  /// Generate random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';

    for (var i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }

    return result;
  }

  /// Count words in text
  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  /// Count characters (excluding spaces)
  static int countCharacters(String text, {bool includeSpaces = true}) {
    if (includeSpaces) {
      return text.length;
    }
    return removeWhitespace(text).length;
  }

  /// Remove accents from text
  static String removeAccents(String text) {
    return text
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[ÀÁÂÃÄÅ]'), 'A')
        .replaceAll(RegExp(r'[ÈÉÊË]'), 'E')
        .replaceAll(RegExp(r'[ÌÍÎÏ]'), 'I')
        .replaceAll(RegExp(r'[ÒÓÔÕÖ]'), 'O')
        .replaceAll(RegExp(r'[ÙÚÛÜ]'), 'U')
        .replaceAll('Ç', 'C');
  }

  /// Wrap text to fit width (for console/display)
  static String wrapText(String text, int maxWidth) {
    if (text.length <= maxWidth) return text;

    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';

    for (final word in words) {
      if ((currentLine + word).length <= maxWidth) {
        currentLine += '${currentLine.isEmpty ? '' : ' '}$word';
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines.join('\n');
  }

  /// Check if string contains only alphanumeric characters
  static bool isAlphanumeric(String text) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);
  }

  /// Check if string contains only letters
  static bool isAlpha(String text) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(text);
  }

  /// Reverse string
  static String reverse(String text) {
    return text.split('').reversed.join('');
  }

  /// Get word at position in text
  static String? getWordAtPosition(String text, int position) {
    if (position < 0 || position >= text.length) return null;

    var start = position;
    var end = position;

    // Find start of word
    while (start > 0 && text[start - 1] != ' ') {
      start--;
    }

    // Find end of word
    while (end < text.length - 1 && text[end + 1] != ' ') {
      end++;
    }

    return text.substring(start, end + 1);
  }
}
