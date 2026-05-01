import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// TODO: IMPORTANT!
// You need to generate your `firebase_options.dart` file.
// 1. Create a Firebase project at console.firebase.google.com.
// 2. Install Firebase CLI: `npm install -g firebase-tools`.
// 3. Log in: `firebase login`.
// 4. Configure your Flutter project: `flutterfire configure`.
//    This will generate `lib/firebase_options.dart`.
// 5. Replace the placeholder below with your actual `FirebaseOptions`.
//    For example: `import 'firebase_options.dart';`
//    And then use `DefaultFirebaseOptions.currentPlatform` in `Firebase.initializeApp()`.

// Placeholder for FirebaseOptions to allow compilation without actual setup.
// This will cause a runtime error if not replaced with a real firebase_options.dart.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this project. '
      'See https://firebase.google.com/docs/flutter/setup for instructions.',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase. Replace `DefaultFirebaseOptions.currentPlatform`
    // with your actual generated options from `firebase_options.dart`.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // This catch block will execute if DefaultFirebaseOptions is not replaced
    // and `firebase_options.dart` is not properly configured.
    // In a real app, you might show an error screen or log this.
    print('Error initializing Firebase: $e');
    // You could also run the app without Firebase functionality for testing UI:
    // runApp(const MyApp(firebaseInitialized: false));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-Time Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Firestore instance to interact with the database.
  final _firestore = FirebaseFirestore.instance;
  // Controller for the message input text field.
  final TextEditingController _messageController = TextEditingController();
  // A simple sender name for demonstration. In a real app, this would come from user authentication.
  final String _currentUser = 'Flutter User';

  // Sends a new message to Firestore.
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      try {
        await _firestore.collection('messages').add({
          'text': text,
          'sender': _currentUser,
          'timestamp': FieldValue.serverTimestamp(), // Use server timestamp for consistency.
        });
        _messageController.clear(); // Clear the input field after sending.
      } catch (e) {
        print('Error sending message: $e');
        // Optionally show a SnackBar or AlertDialog to the user.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            // StreamBuilder listens to real-time updates from Firestore.
            child: StreamBuilder<QuerySnapshot>(
              // Query messages collection, ordered by timestamp.
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: true) // Display newest messages at the bottom.
                  .snapshots(),
              builder: (context, snapshot) {
                // Handle different states of the stream.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet! Say hello.'));
                }

                // If data is available, build the list of messages.
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true, // Reverses the list to show new messages at the bottom.
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(), // Input field and send button.
        ],
      ),
    );
  }

  // Builds an individual message bubble.
  Widget _buildMessageBubble(DocumentSnapshot messageDoc) {
    final messageData = messageDoc.data() as Map<String, dynamic>;
    final messageText = messageData['text'] as String? ?? 'Empty Message';
    final messageSender = messageData['sender'] as String? ?? 'Unknown';
    final isMe = messageSender == _currentUser; // Check if the message was sent by the current user.

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            messageSender,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15.0),
              topRight: const Radius.circular(15.0),
              bottomLeft: isMe ? const Radius.circular(15.0) : const Radius.circular(0),
              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(15.0),
            ),
            elevation: 5.0,
            color: isMe ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(
                messageText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isMe ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the message input area at the bottom of the screen.
  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(), // Send message when enter is pressed.
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              ),
              minLines: 1,
              maxLines: 5, // Allow multi-line input.
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose(); // Dispose controller to prevent memory leaks.
    super.dispose();
  }
}
