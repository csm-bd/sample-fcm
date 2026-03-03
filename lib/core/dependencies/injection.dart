import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import '../../features/notifications/data/datasources/remote.dart';
import '../../features/notifications/data/datasources/remote_impl.dart';
import '../../features/notifications/data/repositories/notification_impl.dart';
import '../../features/notifications/domain/repositories/notification.dart';
import '../../features/notifications/domain/usecases/notification.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! ----------------- External -----------------

  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  //! ----------------- Data sources -----------------

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      messaging: sl(),
      localNotifications: sl(),
    ),
  );

  //! ----------------- Repository -----------------

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remote: sl()),
  );

  //! ----------------- UseCases -----------------

  sl.registerFactory(() => InitializeNotificationsUseCase(repository: sl()));
  sl.registerFactory(
    () => RequestNotificationPermissionUseCase(repository: sl()),
  );
  sl.registerFactory(() => GetDeviceTokenUseCase(repository: sl()));

  //! ----------------- Bloc -----------------

  sl.registerFactory(
    () => NotificationBloc(
      initialize: sl(),
      requestPermission: sl(),
      getDeviceToken: sl(),
    ),
  );
}
