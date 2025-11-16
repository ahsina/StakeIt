import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Initialize Stripe
  Stripe.publishableKey = AppConfig.stripePublishableKey;
  Stripe.merchantIdentifier = 'merchant.com.stakeit';

  runApp(
    const ProviderScope(
      child: StakeItApp(),
    ),
  );
}

/// Initialize app services (called after first build)
Future<void> initializeAppServices(WidgetRef ref) async {
  try {
    // Initialize notifications
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();

    // Get and send FCM token to backend
    final token = await notificationService.getToken();
    if (token != null) {
      await notificationService.sendTokenToBackend(token);
    }

    // Subscribe to general topics
    await notificationService.subscribeToTopic('general');
  } catch (e) {
    print('Service initialization error: $e');
  }
}
