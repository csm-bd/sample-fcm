import 'package:sample_fcm/features/notifications/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<void> requestPermission();
  Future<String?> getDeviceToken();
  Stream<String> get tokenRefreshStream;
  Stream<NotificationEntity> get onForegroundNotification;
  Future<void> initialize();
}
