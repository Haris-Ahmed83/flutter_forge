import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Data model for a single chat message.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isSender, // true if sent by the current user, false if received
    required this.timestamp,
  });

  final String text;
  final bool isSender;
  final DateTime timestamp;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Static Chat UI',
      // Material 3 design enabled
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          // Customizing colors for chat bubbles for better distinction
          primary: Colors.deepPurple, // Color for sender's bubbles
          onPrimary: Colors.white, // Text color on sender's bubbles
          surfaceVariant: Colors.grey.shade200, // Color for receiver's bubbles
          onSurfaceVariant: Colors.black87, // Text color on receiver's bubbles
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16.0),
          bodyMedium: TextStyle(fontSize: 14.0),
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
  // Sample chat messages
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hey there! How are you doing today?',
      isSender: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      text: 'I\'m doing great, thanks for asking! Just finished my morning run.',
      isSender: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      text: 'Oh, that\'s awesome! I wish I had your motivation. I\'m still trying to get out of bed, haha.',
      isSender: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      text: 'Haha, it\'s all about building a routine! What are your plans for the day?',
      isSender: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    ChatMessage(
      text: 'Probably just some work and then maybe a movie later. You?',
      isSender: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    ChatMessage(
      text: 'Sounds good! I have a meeting soon, then planning to work on a new project. Might hit the gym later.',
      isSender: true,
      timestamp: DateTime.now(),
    ),
    ChatMessage(
      text: 'Good luck with the meeting and the project! Enjoy the gym!',
      isSender: false,
      timestamp: DateTime.now().add(const Duration(seconds: 10)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Alex'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: false, // Display messages from top to bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessageBubble(
                  message: message,
                );
              },
            ),
          ),
          const ChatInputBar(), // Input bar at the bottom
        ],
      ),
    );
  }
}

/// A widget to display a single chat message bubble.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Determine bubble color and text color based on sender status
    final Color bubbleColor = message.isSender ? colorScheme.primary : colorScheme.surfaceVariant;
    final Color textColor = message.isSender ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;

    // Determine border radius for chat bubbles
    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16.0),
      topRight: const Radius.circular(16.0),
      bottomLeft: message.isSender ? const Radius.circular(16.0) : const Radius.circular(4.0),
      bottomRight: message.isSender ? const Radius.circular(4.0) : const Radius.circular(16.0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      // Align the bubble to the right for sender, left for receiver
      child: Align(
        alignment: message.isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          // Constrain bubble width to prevent it from stretching across the screen
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
          ),
          padding: const EdgeInsets.all(12.0),
          child: Text(
            message.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}

/// A static input bar for demonstration purposes.
/// In a real app, this would be stateful and handle text input.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
              // This is a static UI, so no actual text controller needed.
              // In a real app, you'd use TextEditingController here.
              readOnly: true, // Make it read-only for static demo
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: () {
              // TODO: Implement message sending logic in a real app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Send button pressed (static demo)')),
              );
            },
            elevation: 0,
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
