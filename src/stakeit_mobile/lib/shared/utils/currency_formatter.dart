import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _euroFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );

  static final NumberFormat _euroFormatNoSymbol = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '',
    decimalDigits: 2,
  );

  /// Format amount as "10,50 €"
  static String format(double amount) {
    return _euroFormat.format(amount);
  }

  /// Format amount as "10,50" (without symbol)
  static String formatWithoutSymbol(double amount) {
    return _euroFormatNoSymbol.format(amount).trim();
  }

  /// Format amount with sign (e.g., "+10,50 €" or "-5,25 €")
  static String formatWithSign(double amount) {
    final sign = amount >= 0 ? '+' : '';
    return '$sign${format(amount)}';
  }

  /// Format amount in compact form (e.g., "1,2K €" or "1,5M €")
  static String formatCompact(double amount) {
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M €';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K €';
    } else {
      return format(amount);
    }
  }

  /// Parse currency string to double (handles "10,50 €" or "10.50" or "10,50")
  static double parse(String input) {
    // Remove currency symbol and spaces
    String cleaned = input
        .replaceAll('€', '')
        .replaceAll(' ', '')
        .trim();

    // Replace comma with dot for parsing
    cleaned = cleaned.replaceAll(',', '.');

    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Validate currency input string
  static bool isValid(String input) {
    try {
      final amount = parse(input);
      return amount >= 0;
    } catch (e) {
      return false;
    }
  }

  /// Format percentage (e.g., "75,5%")
  static String formatPercentage(double value) {
    final formatter = NumberFormat.percentPattern('fr_FR');
    return formatter.format(value / 100);
  }

  /// Format percentage with one decimal (e.g., "75,5%")
  static String formatPercentageWithDecimal(double value) {
    return '${value.toStringAsFixed(1).replaceAll('.', ',')} %';
  }

  /// Format large number with spaces (e.g., "1 234 567,89")
  static String formatLargeNumber(double amount) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    return formatter.format(amount).replaceAll(',', ' ');
  }

  /// Get currency symbol
  static String get currencySymbol => '€';

  /// Format amount for display in card (rounded if large)
  static String formatForCard(double amount) {
    if (amount.abs() >= 1000) {
      return formatCompact(amount);
    } else if (amount == amount.roundToDouble()) {
      // No decimals if it's a whole number
      return '${amount.toInt()} €';
    } else {
      return format(amount);
    }
  }

  /// Format difference with color indication (for profit/loss)
  static String formatDifference(double amount) {
    if (amount == 0) {
      return '0,00 €';
    }
    final sign = amount > 0 ? '+' : '';
    return '$sign${format(amount)}';
  }

  /// Format stake amount (minimum 2 decimals)
  static String formatStakeAmount(double amount) {
    return format(amount);
  }

  /// Format wallet balance
  static String formatBalance(double amount) {
    return format(amount);
  }

  /// Format payout amount
  static String formatPayout(double amount) {
    return format(amount);
  }

  /// Validate amount against minimum
  static bool isAboveMinimum(double amount, double minimum) {
    return amount >= minimum;
  }

  /// Validate amount against maximum
  static bool isBelowMaximum(double amount, double maximum) {
    return amount <= maximum;
  }

  /// Validate amount is in range
  static bool isInRange(double amount, double min, double max) {
    return amount >= min && amount <= max;
  }

  /// Round to 2 decimal places
  static double roundToTwoDecimals(double amount) {
    return (amount * 100).round() / 100;
  }

  /// Calculate percentage of total
  static double calculatePercentage(double part, double total) {
    if (total == 0) return 0;
    return (part / total) * 100;
  }

  /// Format as percentage of total
  static String formatAsPercentageOfTotal(double part, double total) {
    final percentage = calculatePercentage(part, total);
    return formatPercentageWithDecimal(percentage);
  }
}
