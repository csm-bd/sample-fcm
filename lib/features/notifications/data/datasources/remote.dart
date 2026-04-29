import 'package:sample_fcm/features/notifications/domain/entities/notification.dart';

abstract class NotificationRemoteDataSource {
  Future<void> requestPermission();
  Future<String?> getToken();
  Stream<String> get tokenRefreshStream;
  Stream<NotificationEntity> get onForegroundNotification;
  Future<void> initialize();
}
