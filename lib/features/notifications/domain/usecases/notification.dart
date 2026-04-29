import '../repositories/notification.dart';

class InitializeNotificationsUseCase {
  final NotificationRepository repository;

  const InitializeNotificationsUseCase({required this.repository});

  Future<void> call() => repository.initialize();
}

class RequestNotificationPermissionUseCase {
  final NotificationRepository repository;

  const RequestNotificationPermissionUseCase({required this.repository});

  Future<void> call() => repository.requestPermission();
}

class GetDeviceTokenUseCase {
  final NotificationRepository repository;

  const GetDeviceTokenUseCase({required this.repository});

  Future<String?> call() => repository.getDeviceToken();
}
