# Push Notifications 🔔
> A Flutter project demonstrating the integration and handling of push notifications using Firebase Messaging.

## Description
This project showcases the fundamental implementation of push notifications in a Flutter application. It leverages Firebase Cloud Messaging (FCM) to enable real-time message delivery to user devices, covering various notification states and interaction patterns. The aim is to provide a clear, functional example for developers looking to add robust notification capabilities to their Flutter apps.

## Features
*   **Firebase Integration:** Seamless setup and initialization of Firebase services within a Flutter app.
*   **Permission Handling:** Requests and manages user permissions for displaying notifications on both Android and iOS.
*   **Foreground Message Handling:** Displays and processes notifications received while the app is actively running.
*   **Background/Terminated Message Handling:** Configures handlers for notifications received when the app is in the background or completely closed.
*   **Notification Interaction:** Demonstrates how to respond to user taps on notifications to navigate within the app.
*   **Device Token Retrieval:** Shows how to obtain the unique FCM device token for targeted messaging.
*   **Test Notifications:** Easily test notification delivery using the Firebase Console.

## Key Concepts Demonstrated
*   **Firebase Messaging (FCM) Integration:** Setting up and configuring Firebase Cloud Messaging for Flutter.
*   **Notification Permissions:** Requesting and managing user consent for push notifications.
*   **Foreground Message Handling:** Using `FirebaseMessaging.onMessage` to process notifications while the app is open.
*   **Background and Terminated Message Handling:** Implementing `FirebaseMessaging.onBackgroundMessage` and `onMessageOpenedApp` for notifications when the app is not active.
*   **Device Registration Token:** Understanding and retrieving the unique token for sending targeted messages.
*   **Notification Payload Data:** Extracting and utilizing custom data sent within notification payloads.

## Getting Started
To run this project locally, follow these steps:

1.  **Firebase Project Setup:**
    *   Create a new project in the [Firebase Console](https://console.firebase.google.com/).
    *   Add an Android app and an iOS app to your Firebase project, following the instructions to download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) and place them in the correct directories (`android/app` and `ios/Runner` respectively).
    *   Enable Cloud Messaging in your Firebase project.
2.  **Clone the repository:**
    ```bash
    git clone https://github.com/Haris-Ahmed83/flutter_forge.git
    cd flutter_forge/projects/40_push_notifications
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```

## Screenshots
*(Add screenshots or GIFs of the application in action here)*

## Author
- HarisAhmed83 - https://github.com/Haris-Ahmed83

Part of the [flutter_forge](https://github.com/Haris-Ahmed83/flutter_forge) series.
