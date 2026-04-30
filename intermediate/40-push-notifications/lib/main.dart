import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer; // For logging

// TODO: Ensure you have added firebase_core and firebase_messaging to your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   firebase_core: ^latest_version
//   firebase_messaging: ^latest_version

// TODO: After adding dependencies, run `flutter pub get`.
// TODO: Then, configure Firebase for your project by following these steps:
// 1. Create a Firebase project at console.firebase.google.com.
// 2. Register your Android and iOS apps in the Firebase project.
// 3. Download the `google-services.json` for Android and place it in `android/app/`.
// 4. Download the `GoogleService-Info.plist` for iOS and place it in `ios/Runner/`.
// 5. Run `flutterfire configure` in your project root to generate `lib/firebase_options.dart`.
// 6. Ensure `firebase_options.dart` is correctly generated and imported below.

// A top-level function to handle background messages.
// This function must be a top-level function (not a method of a class)
// and cannot access the UI state directly.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background messages.
  // This is crucial if the app is terminated and a background message arrives.
  await Firebase.initializeApp(
      // TODO: Replace with your actual firebase_options.dart if generated.
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  developer.log('Handling a background message: ${message.messageId}');
  developer.log('Message data: ${message.data}');
  developer.log('Message notification: ${message.notification?.title}');
  developer.log('Message notification body: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase App
  await Firebase.initializeApp(
      // TODO: Replace with your actual firebase_options.dart if generated.
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  // Set up the background message handler.
  // This must be called before `runApp`.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Push Notifications',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _fcmToken;
  RemoteMessage? _initialMessage;
  final List<RemoteMessage> _messages = []; // Stores foreground/background messages

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Request permission for notifications (iOS & Web)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    developer.log('User granted permission: ${settings.authorizationStatus}');

    // 2. Get and display the FCM token
    _fcmToken = await messaging.getToken();
    developer.log('FCM Token: $_fcmToken');
    setState(() {}); // Update UI with token

    // 3. Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Got a message whilst in the foreground!');
      developer.log('Message data: ${message.data}');

      if (message.notification != null) {
        developer.log('Message also contained a notification: ${message.notification!.title}, ${message.notification!.body}');
      }
      setState(() {
        _messages.add(message);
      });
    });

    // 4. Handle messages when the app is opened from a terminated state
    // (e.g., by tapping on a notification)
    _initialMessage = await messaging.getInitialMessage();
    if (_initialMessage != null) {
      developer.log('App opened from terminated state with message: ${_initialMessage!.messageId}');
      developer.log('Initial Message data: ${_initialMessage!.data}');
    }

    // 5. Handle messages when the app is in the background but not terminated,
    // and the user taps on the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('A new onMessageOpenedApp event was published!');
      developer.log('Message data: ${message.data}');
      setState(() {
        _messages.add(message);
      });
      // You can navigate to a specific screen based on message data here.
    });

    // 6. Subscribe to a topic (optional for targeted notifications)
    await messaging.subscribeToTopic('all_users');
    developer.log('Subscribed to topic: all_users');
  }

  Future<void> _refreshFcmToken() async {
    await FirebaseMessaging.instance.deleteToken(); // Invalidate current token
    _fcmToken = await FirebaseMessaging.instance.getToken(); // Get new token
    developer.log('Refreshed FCM Token: $_fcmToken');
    setState(() {});
  }

  Future<void> _unsubscribeFromTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
    developer.log('Unsubscribed from topic: all_users');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unsubscribed from "all_users" topic')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FCM Token:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _fcmToken == null
                  ? const CircularProgressIndicator()
                  : SelectableText(
                      _fcmToken!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _refreshFcmToken,
                    child: const Text('Refresh Token'),
                  ),
                  ElevatedButton(
                    onPressed: _unsubscribeFromTopic,
                    child: const Text('Unsubscribe Topic'),
                  ),
                ],
              ),
              const Divider(height: 32),
              Text(
                'Initial Message (from terminated app):',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _initialMessage == null
                  ? Text(
                      'No initial message received.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : _buildMessageCard(_initialMessage!),
              const Divider(height: 32),
              Text(
                'Received Messages (Foreground/Opened):',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _messages.isEmpty
                  ? Text(
                      'No messages received yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageCard(_messages[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(RemoteMessage message) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.notification?.title ?? 'No Title',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              message.notification?.body ?? 'No Body',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Data: ${message.data}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Message ID: ${message.messageId ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Sent: ${message.sentTime?.toLocal() ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
