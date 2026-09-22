import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/core/services/notification_service.dart';

/// Top-level background message handler required by Firebase Messaging.
/// Must be annotated with @pragma('vm:entry-point') to prevent tree shaking.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase already initialized
  }
  debugPrint('Handling background FCM message: ${message.messageId}');
}

class FcmService extends GetxService {
  static FcmService get to => Get.find<FcmService>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final RxnString fcmToken = RxnString();
  final RxBool hasPermission = false.obs;

  Future<FcmService> init() async {
    // Only proceed on supported platforms (Android, iOS, Web, macOS)
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _setupFcm();
    }
    return this;
  }

  Future<void> _setupFcm() async {
    try {
      // 1. Request permissions (Android 13+ and iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      hasPermission.value =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      // 2. Set foreground presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        debugPrint('FCM Token: $token');
        await syncTokenToFirestore(token);
      }

      // 4. Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        fcmToken.value = newToken;
        debugPrint('FCM Token refreshed: $newToken');
        await syncTokenToFirestore(newToken);
      });

      // 5. Subscribe to broadcast topics
      try {
        await _messaging.subscribeToTopic('all_users');
        await _messaging.subscribeToTopic('habits');
      } catch (e) {
        debugPrint('Failed to subscribe to topics: $e');
      }

      // 6. Foreground message listener (Show in-app local notification)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message received: ${message.messageId}');
        final notification = message.notification;
        if (notification != null) {
          NotificationService().showNotification(
            id: message.hashCode,
            title: notification.title ?? 'Habit Tracker',
            body: notification.body ?? '',
            channelId: 'fcm_channel',
            channelName: 'Firebase Notifications',
            payload: message.data.toString(),
          );
        }
      });

      // 7. Notification tap handling when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened from background via notification: ${message.data}');
      });

      // 8. Notification tap handling when app was terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App opened from terminated state via notification: ${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('Error setting up FCM: $e');
    }
  }

  /// Syncs FCM Token to Firestore under the current user's profile
  Future<void> syncTokenToFirestore([String? tokenToSync]) async {
    final token = tokenToSync ?? fcmToken.value;
    if (token == null) return;

    try {
      if (Get.isRegistered<FirestoreService>()) {
        final firestoreService = Get.find<FirestoreService>();
        if (firestoreService.isUserLoggedIn) {
          await firestoreService.saveFcmToken(token);
        }
      }
    } catch (e) {
      debugPrint('Failed to sync FCM token to Firestore: $e');
    }
  }

  /// Removes FCM Token on logout
  Future<void> clearTokenFromFirestore() async {
    try {
      if (Get.isRegistered<FirestoreService>()) {
        final firestoreService = Get.find<FirestoreService>();
        if (firestoreService.isUserLoggedIn) {
          await firestoreService.removeFcmToken();
        }
      }
    } catch (e) {
      debugPrint('Failed to clear FCM token from Firestore: $e');
    }
  }
}
