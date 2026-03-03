import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification.dart';
import '../../domain/usecases/notification.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final InitializeNotificationsUseCase initialize;
  final RequestNotificationPermissionUseCase requestPermission;
  final GetDeviceTokenUseCase getDeviceToken;

  NotificationBloc({
    required this.initialize,
    required this.requestPermission,
    required this.getDeviceToken,
  }) : super(const NotificationInitial()) {
    debugPrint('NotificationBloc initialized');
    on<InitializeNotification>(_onInitialize);
    on<NotificationReceived>(_onNotificationReceived);
  }

  Future<void> _onInitialize(
    InitializeNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await initialize();
      await requestPermission();

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        debugPrint('FCM token refreshed: $token');
        emit(NotificationReady(token));
      });

      // await Future.delayed(const Duration(seconds: 3));

      final token = await getDeviceToken();
      if (token != null) {
        debugPrint('FCM token immediately available: $token');
        emit(NotificationReady(token));
      } else {
        debugPrint(
          'Device token not yet available, waiting for onTokenRefresh...',
        );
      }
    } catch (e, st) {
      debugPrint('Error in _onInitialize: $e\n$st');
    }
  }

  void _onNotificationReceived(NotificationReceived event, Emitter emit) {
    debugPrint('NotificationReceived');
    emit(NotificationReceived(notification: event.notification));
  }
}
