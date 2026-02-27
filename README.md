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
- Click Next, Done!

## STEP 9: Enable Capabilities in Xcode
Open in Xcode:
```bash
ios/Runner.xcworkspace
```
Go to:
- Signing & Capabilities →
- Enable: Push Notifications (+Capability)
- Enable: Background Modes → Remote notifications (+Capability)

## STEP 10: Upload APNs Key to Firebase
- Apple Developer Account
- Create APNs Auth Key or Use Existing Key
- Download .p8 file
- Go to Firebase →
- Project Settings →
- Cloud Messaging →
- Upload APNs key

## STEP 11: Flutter Implementation (TODO)
## STEP 00: Sending Push Notification from Firebase Console
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

## STEP 00: Generate Oauth Access Token using Google Cloud SDK
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
## STEP 00: Postman Request
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