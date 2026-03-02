import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sample_fcm/features/notifications/data/datasources/remote.dart';
import 'package:sample_fcm/features/notifications/domain/entities/notification.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin localNotifications;

  NotificationRemoteDataSourceImpl({
    required this.messaging,
    required this.localNotifications,
  });

  @override
  Future<void> requestPermission() async {
    await messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  @override
  Future<String?> getToken() async {
    try {
      await requestPermission();

      await Future.delayed(const Duration(seconds: 2));

      String? token = await messaging.getToken();

      token ??= await messaging.onTokenRefresh.first;

      debugPrint('FCM/APNs Token: $token');
      return token;
    } catch (e) {
      debugPrint('getToken() failed: $e');
      return null;
    }
  }

  @override
  Stream<String> get tokenRefreshStream => messaging.onTokenRefresh;

  @override
  Stream<NotificationEntity> get onForegroundNotification =>
      FirebaseMessaging.onMessage.map((message) {
        return NotificationEntity(
          guid: message.messageId.toString(),
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          data: message.data,
        );
      });

  @override
  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    final iosInit = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications.',
      importance: Importance.max,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((message) async {
      await localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title,
        body: message.notification?.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }
}
