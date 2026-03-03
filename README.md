# 🔥 Flutter FCM Integration Guide
This project demonstrates how to integrate Firebase Cloud Messaging (FCM) in a Flutter app for both Android and iOS, including:

- ✅ Foreground notifications
- ✅ Background notifications
- ✅ Terminated state notifications
- ✅ Sending push notifications from Firebase Console
- ✅ Sending push notifications using Postman (HTTP v1 API)

## Step 1: Create Flutter Project
Create a new Flutter project using the usual Flutter commands:

```bash
flutter create your_project_name
```
## Step 2: Change Application Package Name
### Install the Package
  - Install the package using this command in your terminal:
  ```bash 
  flutter pub add change_app_package_name
  ```
### Change the Package Name
  - Then run this command to change the package name for both platforms (replace com.your_package_name with your desired package name):
  ```bash 
  dart run change_app_package_name:main com.your_package_name
  ```
## Step 3: Add Dependencies
- Add to pubspec.yaml:
```bash
dependencies:
  firebase_core: ^latest_version
  firebase_messaging: ^latest_version
  flutter_local_notifications: ^latest_version
```
- Then:
```bash
flutter pub get
```
### 🔧 Fix: flutter_local_notifications Requires Core Library Desugaring (Android)
When building the project, you may encounter this error:
```bash
Execution failed for task ':app:checkDebugAarMetadata'.
Dependency ':flutter_local_notifications' requires core library desugaring to be enabled.
```
This happens because flutter_local_notifications uses newer Java 8+ APIs that require Core Library Desugaring for Android.
#### Let's fix this issue
- Open Android App Build File
```bash
android/app/build.gradle.kts
```
- Enable Core Library Desugaring
- Inside the android {} block, update or add the following:
```bash
compileOptions {
    isCoreLibraryDesugaringEnabled = true
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlinOptions {
    jvmTarget = "17"
}
```
- Add Desugaring Dependency
- At the bottom of the same file (outside the android {} block), add:
```bash
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```
- Clean and Rebuild the Project
```bash
flutter clean
flutter pub get
flutter run
```
## Step 4: Create Firebase Project
- Go to: https://console.firebase.google.com
- Click Create a new Firebase project
- Enter your project name and continue
- Enable AI assistance for your project and continue
- Disable Google Analytics for your project (Optional)
- Click Create Project and continue

### 🤖 ANDROID CONFIGURATION
## Step 5: Add Android App to Firebase
- In your project on Firebase, Click + Add App
- Click on Android Icon from the platform row
- Add Android package name
```bash
com.codecraft.fcm
```
(Must match android/app/build.gradle.kts)
- Add app nickname (Optional)
- Click on Register App button
- Download google-services.json
- Place it inside:
```bash
android/app/google-services.json
```
- Click Next to continue
- Add Firebase SDK to your proejct
- Click Next and Next
- Done

## Step 6: Add Firebase SDK
- android/settings.gradle
```bash
plugins{
    id("com.google.gms.google-services") version "4.3.15" apply false
}
```
- android/app/build.gradle
```bash
plugins {
    id("com.google.gms.google-services")
}
```
## Step 7: Android Notification Permission (Android 13+)
- Add in: android/app/src/main/AndroidManifest.xml
```bash
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```
### 🍎 iOS CONFIGURATION
## Step 8: Add iOS App to Firebase
- Click + Add App
- Click on iOS Icon from the platform row
- Add Apple bundle id
- Bundle ID must match:
```bash
ios/Runner.xcodeproj → General → Identity → Bundle Identifier
```
- Add App nickname (Optional)
- Click on Register App
- Download GoogleService-Info.plist
- Add inside:
```bash 
ios/Runner/
```
- Click Next (No need to add Firebase SDK)
- Add initialization code in AppDelegate.swift
```bash
ios/Runner/AppDelegate.swift
```
- Example Code
```dart
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        application.registerForRemoteNotifications()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.newData)
    }
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        print("APNs device token registered: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
    }
}
```
## STEP 9: Enable Capabilities in Xcode
Open in Xcode:
```bash
ios/Runner.xcworkspace
```
Go to:
- Signing & Capabilities →
- Enable: Push Notifications (+ Capability)
- Enable: Background Modes → Remote notifications (+ Capability)

## STEP 10: Upload APNs Key to Firebase
- Apple Developer Account
- Create APNs Auth Key or Use Existing Key
- Download .p8 file
- Go to Firebase
- Click on your project settings icon
- Then Go To Cloud Messaging Tab
- Upload APNs key

## STEP 11: Flutter Implementation
We will implement push notification in Flutter using BLoc and Clean Architecture.
- Create notification features inside lib
```bash
lib
└── features
        └── notifications
            ├── data
            │   ├── datasources
            │   ├── models
            │   └── repositories
            ├── domain
            │   ├── entities
            │   ├── repositories
            │   └── usecases
            └── presentation
                ├── bloc
                └── pages
```
- Initialize Firebase Globally
```dart
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MainApp());
}
```
- Add Equatable Package to Your Project.
```bash
flutter pub add equatable
```
### 📦 DOMAIN LAYER
- Create Notification Entity
```bash
domain/entities/notification.dart
```
```dart
class NotificationEntity extends Equatable {
  final String guid;
  final String title;
  final String body;
  final Map<String, dynamic> data;

  const NotificationEntity({
    required this.guid,
    required this.title,
    required this.body,
    required this.data,
  });

  @override
  List<Object?> get props => [guid, title, body, data];
}
```
- Create Notification Repository
```bash
domain/repositories/notification.dart
```
```dart
abstract class NotificationRepository {
  Future<void> requestPermission();
  Future<String?> getDeviceToken();
  Stream<String> get tokenRefreshStream;
  Stream<NotificationEntity> get onForegroundNotification;
  Future<void> initialize();
}
```
- Create Usecases
```bash
domain/usecases/notification.dart
```
- Request Permission Usecase
```dart
class RequestNotificationPermissionUseCase {
  final NotificationRepository repository;

  const RequestNotificationPermissionUseCase({required this.repository});

  Future<void> call() => repository.requestPermission();
}
```
- Get Token Usecase
```dart
class GetDeviceTokenUseCase {
  final NotificationRepository repository;

  const GetDeviceTokenUseCase({required this.repository});

  Future<String?> call() => repository.getDeviceToken();
}
```
- Initialize Usecase
```dart
class InitializeNotificationsUseCase {
  final NotificationRepository repository;

  const InitializeNotificationsUseCase({required this.repository});

  Future<void> call() => repository.initialize();
}
```
### 📦 DATA LAYER
- Create Remote Data Source
```bash
data/datasources/remote.dart
```
```dart
abstract class NotificationRemoteDataSource {
  Future<void> requestPermission();
  Future<String?> getToken();
  Stream<String> get tokenRefreshStream;
  Stream<NotificationEntity> get onForegroundNotification;
  Future<void> initialize();
}
```
- Implement Remote Data Source
```bash
data/datasources/remote_impl.dart
```
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sample_fcm/features/notifications/data/datasources/remote.dart';

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
```
- Implement Repository
```bash
data/repositories/notification.dart
```
```dart
import 'package:sample_fcm/features/notifications/data/datasources/remote.dart';
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
```
### 📦 PRESENTATION LAYER (BLoC)
- Notification State
```dart
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
```
- Notification Event
```dart
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
```
- Notification Bloc
```dart
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
```
### 🔔 FCM Dependency Injection Setup
- Install Required Package
```bash
get_it: ^latest
```
- Then run:
```bash
flutter pub get
```
- Create Injection File
```bash
lib/core/dependencies/injection.dart
```
- Configure Get It
```dart
final sl = GetIt.instance;

Future<void> init() async {

  //! ----------------- External Dependencies -----------------

  sl.registerLazySingleton<FirebaseMessaging>(
    () => FirebaseMessaging.instance,
  );

  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  //! ----------------- Data Sources -----------------

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      messaging: sl(),
      localNotifications: sl(),
    ),
  );

  //! ----------------- Repository -----------------

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remote: sl(),
    ),
  );

  //! ----------------- Use Cases -----------------

  sl.registerFactory(
    () => InitializeNotificationsUseCase(repository: sl()),
  );

  sl.registerFactory(
    () => RequestNotificationPermissionUseCase(repository: sl()),
  );

  sl.registerFactory(
    () => GetDeviceTokenUseCase(repository: sl()),
  );

  //! ----------------- Bloc -----------------

  sl.registerFactory(
    () => NotificationBloc(
      initialize: sl(),
      requestPermission: sl(),
      getDeviceToken: sl(),
    ),
  );
}
```
- Initialize Get It in main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await init(); // Initialize Get It

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  runApp(
    BlocProvider(
      create: (_) => sl<NotificationBloc>(),
      child: const MainApp(),
    ),
  );
}
```
- Trigger Notification Initialization in HomePage
```dart
 @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(InitializeNotification());
  }
  ```
## STEP 12: Sending Push Notification from Firebase Console
- Go to Firebase Console
- Go to Run > Messaging
- Create Your First Campaign > Push Notification
- Enter: Title, Body, Select Target:
- Complete Additional Steps
- Click Send

## STEP 00: Sending Push Notification using Postman (HTTP v1)
- Go to:
- Firebase →
- Project Settings →
- Service Accounts →
- Generate New Private Key
- Download JSON file.

## STEP 13: Generate Oauth Access Token using Google Cloud SDK
- Install Google Cloud SDK
```bash
brew install --cask google-cloud-sdk
```
- Initialize gcloud
```bash
gcloud init
```
- Then: Login with your Google account.
- Activate Your Firebase Service Account using the Downloaded JSON File
- In Terminal run:
```bash
gcloud auth activate-service-account --key-file=/path/to/your/firebase-service-account.json
```
- Generate OAuth Token
```bash
gcloud auth print-access-token
```
- Copy that token and use it in Postman header:
```bash
Authorization: Bearer YOUR_TOKEN_HERE
```
## STEP 14: Postman Request
- URL:
```bash
POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send
```
- Headers:
```bash
Authorization: Bearer ACCESS_TOKEN
Content-Type: application/json
```
- Body (Raw JSON)
```bash
{
  "message": {
    "token": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Hello",
      "body": "This is a test message"
    }
  }
}
```
- Click Send