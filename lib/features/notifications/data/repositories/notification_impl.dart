import 'package:sample_fcm/features/notifications/data/datasources/remote.dart';
import 'package:sample_fcm/features/notifications/domain/entities/notification.dart';
import 'package:sample_fcm/features/notifications/domain/repositories/notification.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remote;

  NotificationRepositoryImpl({required this.remote});

  @override
  Future<void> requestPermission() => remote.requestPermission();

  @override
  Future<String?> getDeviceToken() => remote.getToken();

  @override
  Stream<String> get tokenRefreshStream => remote.tokenRefreshStream;

  @override
  Stream<NotificationEntity> get onForegroundNotification =>
      remote.onForegroundNotification;

  @override
  Future<void> initialize() => remote.initialize();
}
