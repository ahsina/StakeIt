import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/stakes/presentation/create_stake_screen.dart';
import '../../features/stakes/presentation/stake_detail_screen.dart';
import '../../features/challenges/presentation/create_challenge_screen.dart';
import '../../features/challenges/presentation/challenge_detail_screen.dart';
import '../../features/payment/presentation/wallet_screen.dart';

// Route paths
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String createStake = '/create-stake';
  static const String stakeDetail = '/stakes/:id';
  static const String challenges = '/challenges';
  static const String challengeDetail = '/challenges/:id';
  static const String createChallenge = '/create-challenge';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  // final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Routes (with bottom nav)
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Stakes
          GoRoute(
            path: 'create-stake',
            name: 'createStake',
            builder: (context, state) => const CreateStakeScreen(),
          ),
          GoRoute(
            path: 'stakes/:id',
            name: 'stakeDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return StakeDetailScreen(stakeId: int.parse(id));
            },
          ),

          // Challenges
          GoRoute(
            path: 'challenges',
            name: 'challenges',
            builder: (context, state) => const ChallengesScreen(),
          ),
          GoRoute(
            path: 'challenges/:id',
            name: 'challengeDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ChallengeDetailScreen(challengeId: int.parse(id));
            },
          ),
          GoRoute(
            path: 'create-challenge',
            name: 'createChallenge',
            builder: (context, state) => const CreateChallengeScreen(),
          ),

          // Profile
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),

          // Wallet
          GoRoute(
            path: 'wallet',
            name: 'wallet',
            builder: (context, state) => const WalletScreen(),
          ),
        ],
      ),
    ],

    // Redirect logic (check auth state)
    redirect: (context, state) {
      // final isAuthenticated = authState.value != null;
      // final isAuthRoute = state.matchedLocation.startsWith('/login') ||
      //     state.matchedLocation.startsWith('/register') ||
      //     state.matchedLocation == '/';

      // if (!isAuthenticated && !isAuthRoute) {
      //   return AppRoutes.login;
      // }

      // if (isAuthenticated && isAuthRoute && state.matchedLocation != '/') {
      //   return AppRoutes.home;
      // }

      return null; // No redirect
    },

    errorBuilder: (context, state) => const ErrorScreen(),
  );
});

// Placeholder screens (to be implemented)

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Screen - To be implemented')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen - To be implemented')),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Page not found')),
    );
  }
}
