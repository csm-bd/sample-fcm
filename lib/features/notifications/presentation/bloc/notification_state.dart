part of 'notification_bloc.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationReady extends NotificationState {
  final String? token;

  const NotificationReady(this.token);
}

class NotificationLoaded extends NotificationState {
  final NotificationEntity notification;

  const NotificationLoaded({required this.notification});
}
