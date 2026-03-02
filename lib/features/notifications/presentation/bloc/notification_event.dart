part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNotification extends NotificationEvent {}

class NotificationReceived extends NotificationEvent {
  final NotificationEntity notification;

  const NotificationReceived({required this.notification});
}
