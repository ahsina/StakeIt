import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

/// Global navigation service for handling navigation from notifications and other contexts
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static GoRouter? _router;

  static void setRouter(GoRouter router) {
    _router = router;
  }

  static BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to a route
  static void navigateTo(String route) {
    if (_router != null) {
      _router!.go(route);
    } else if (context != null) {
      context!.go(route);
    }
  }

  /// Navigate to stake detail
  static void navigateToStake(int stakeId) {
    navigateTo('${AppRoutes.home}/stakes/$stakeId');
  }

  /// Navigate to challenge detail
  static void navigateToChallenge(int challengeId) {
    navigateTo('${AppRoutes.home}/challenges/$challengeId');
  }

  /// Navigate to notifications screen
  static void navigateToNotifications() {
    navigateTo('${AppRoutes.home}/notifications');
  }

  /// Navigate to home with specific tab
  static void navigateToHome({int tabIndex = 0}) {
    navigateTo(AppRoutes.home);
    // Tab index can be set via a state provider if needed
  }

  /// Handle notification navigation based on payload
  static void handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    if (type == null) return;

    switch (type) {
      case 'stake':
      case 'stake_reminder':
      case 'stake_completed':
      case 'stake_failed':
        if (id != null) {
          navigateToStake(int.parse(id));
        }
        break;

      case 'challenge':
      case 'challenge_started':
      case 'challenge_completed':
      case 'challenge_message':
        if (id != null) {
          navigateToChallenge(int.parse(id));
        }
        break;

      case 'payment':
      case 'payout_completed':
        navigateTo('${AppRoutes.home}/wallet');
        break;

      case 'badge_earned':
      case 'level_up':
        navigateToHome(tabIndex: 2); // Profile tab
        break;

      default:
        navigateToHome();
    }
  }
}
