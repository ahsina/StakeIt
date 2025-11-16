import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Format date as "15 janvier 2024"
  static String formatLongDate(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy', 'fr_FR');
    return formatter.format(date);
  }

  /// Format date as "15 janv. 2024"
  static String formatMediumDate(DateTime date) {
    final formatter = DateFormat('d MMM yyyy', 'fr_FR');
    return formatter.format(date);
  }

  /// Format date as "15/01/2024"
  static String formatShortDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  /// Format time as "14:30"
  static String formatTime(DateTime date) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }

  /// Format date and time as "15/01/2024 14:30"
  static String formatDateTime(DateTime date) {
    return '${formatShortDate(date)} ${formatTime(date)}';
  }

  /// Format date and time as "15 janvier 2024 à 14:30"
  static String formatLongDateTime(DateTime date) {
    return '${formatLongDate(date)} à ${formatTime(date)}';
  }

  /// Format relative time (e.g., "il y a 2 heures", "dans 3 jours")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      // Future date
      final absDifference = date.difference(now);
      return _formatFutureTime(absDifference);
    } else {
      // Past date
      return _formatPastTime(difference);
    }
  }

  static String _formatPastTime(Duration difference) {
    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Il y a $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Il y a $hours heure${hours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Il y a $days jour${days > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }

  static String _formatFutureTime(Duration difference) {
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Dans $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Dans $hours heure${hours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Dans $days jour${days > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Dans $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Dans $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Dans $years an${years > 1 ? 's' : ''}';
    }
  }

  /// Format duration as "2h 30min" or "45min" or "30s"
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      if (minutes > 0) {
        return '${hours}h ${minutes}min';
      }
      return '${hours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Format time remaining (e.g., "2 jours 5h 30min")
  static String formatTimeRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return 'Terminé';
    }

    if (difference.inDays > 0) {
      final days = difference.inDays;
      final hours = difference.inHours.remainder(24);
      if (hours > 0) {
        return '$days jour${days > 1 ? 's' : ''} ${hours}h';
      }
      return '$days jour${days > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      if (minutes > 0) {
        return '${hours}h ${minutes}min';
      }
      return '${hours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return '${difference.inSeconds}s';
    }
  }

  /// Get day of week name in French
  static String getDayName(DateTime date) {
    final formatter = DateFormat('EEEE', 'fr_FR');
    return formatter.format(date);
  }

  /// Get month name in French
  static String getMonthName(DateTime date) {
    final formatter = DateFormat('MMMM', 'fr_FR');
    return formatter.format(date);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Format date with context (e.g., "Aujourd'hui", "Hier", or full date)
  static String formatContextualDate(DateTime date) {
    if (isToday(date)) {
      return 'Aujourd\'hui à ${formatTime(date)}';
    } else if (isYesterday(date)) {
      return 'Hier à ${formatTime(date)}';
    } else if (isTomorrow(date)) {
      return 'Demain à ${formatTime(date)}';
    } else if (date.difference(DateTime.now()).inDays.abs() < 7) {
      return '${getDayName(date)} à ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }
}
