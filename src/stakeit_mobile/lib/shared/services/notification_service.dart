import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'navigation_service.dart';
import 'api_client.dart';

// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationService(dio);
});

class NotificationService {
  final Dio _dio;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  NotificationService(this._dio);

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Request permission
    await _requestPermission();

    // Configure local notifications
    await _configureLocalNotifications();

    // Configure FCM
    await _configureFCM();

    _initialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User declined or has not accepted notification permission');
    }
  }

  /// Configure local notifications
  Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const generalChannel = AndroidNotificationChannel(
      'general',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.high,
    );

    const stakesChannel = AndroidNotificationChannel(
      'stakes',
      'Stakes Notifications',
      description: 'Notifications about your stakes',
      importance: Importance.high,
    );

    const challengesChannel = AndroidNotificationChannel(
      'challenges',
      'Challenges Notifications',
      description: 'Notifications about challenges',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(stakesChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(challengesChannel);
  }

  /// Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Handling foreground message: ${message.messageId}');

    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'StakeIt',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
      channelId: message.data['type'] ?? 'general',
    );
  }

  /// Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');

    // Navigate to appropriate screen based on message data
    if (message.data.isNotEmpty) {
      NavigationService.handleNotificationNavigation(message.data);
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');

    // Navigate based on payload
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        // Parse payload as JSON
        final data = json.decode(response.payload!) as Map<String, dynamic>;
        NavigationService.handleNotificationNavigation(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
        // If parsing fails, just navigate to home
        NavigationService.navigateToHome();
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'general',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      final token = await _fcm.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Send token to backend
  Future<void> sendTokenToBackend(String token) async {
    try {
      await _dio.post(
        '/api/notifications/register-device',
        data: {
          'fcmToken': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'deviceInfo': {
            'platform': Platform.operatingSystem,
            'version': Platform.operatingSystemVersion,
          },
        },
      );
      print('Successfully sent FCM token to backend');
    } catch (e) {
      print('Error sending FCM token to backend: $e');
      // Don't throw - this is not critical
    }
  }

  /// Show custom notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // Handle background message
}

// Notification types
enum NotificationType {
  stakeReminder,
  stakeCompleted,
  stakeFailed,
  challengeInvite,
  challengeStarted,
  challengeMessage,
  challengeCompleted,
  paymentReceived,
  paymentFailed,
}

extension NotificationTypeX on NotificationType {
  String get channelId {
    switch (this) {
      case NotificationType.stakeReminder:
      case NotificationType.stakeCompleted:
      case NotificationType.stakeFailed:
        return 'stakes';
      case NotificationType.challengeInvite:
      case NotificationType.challengeStarted:
      case NotificationType.challengeMessage:
      case NotificationType.challengeCompleted:
        return 'challenges';
      case NotificationType.paymentReceived:
      case NotificationType.paymentFailed:
        return 'general';
    }
  }
}
