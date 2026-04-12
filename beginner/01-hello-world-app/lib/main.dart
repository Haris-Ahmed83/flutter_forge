import 'package:flutter/material.dart';

void main() {
  // Runs the main application widget.
  runApp(const MyApp());
}

/// The root widget of the application.
/// It sets up the MaterialApp, which provides the basic app structure and Material Design.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World App', // Title displayed by the OS for the app.
      theme: ThemeData(
        // Defines the overall visual theme for the app.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Generates a color scheme based on a primary seed color.
        useMaterial3: true, // Enables Material 3 design system features.
      ),
      home: const MyHomePage(title: 'Hello World Home Page'), // The widget displayed on the app's home screen.
      debugShowCheckedModeBanner: false, // Hides the "DEBUG" banner in debug mode.
    );
  }
}

/// The home page of the application, a StatefulWidget to demonstrate state changes.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title; // Title for the app bar, passed from MyApp.

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// The state class for MyHomePage.
/// Manages the current message displayed on the screen and allows it to change.
class _MyHomePageState extends State<MyHomePage> {
  String _currentMessage = 'Hello World!'; // Initial message displayed.

  /// Toggles the displayed message between "Hello World!" and "Flutter is awesome!".
  void _toggleMessage() {
    // setState notifies the Flutter framework that the internal state of this object has changed,
    // which causes the UI to be rebuilt with the updated state.
    setState(() {
      if (_currentMessage == 'Hello World!') {
        _currentMessage = 'Flutter is awesome!';
      } else {
        _currentMessage = 'Hello World!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold provides a basic Material Design visual structure for the screen.
    return Scaffold(
      appBar: AppBar(
        // The app bar at the top of the screen.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Uses a color from the theme.
        title: Text(widget.title), // Displays the title passed to MyHomePage.
      ),
      body: Center(
        // Centers its child widget within the available space.
        child: Column(
          // Arranges its children in a vertical array.
          mainAxisAlignment: MainAxisAlignment.center, // Centers children vertically in the column.
          children: <Widget>[
            // Displays the current message with a large, bold style.
            Text(
              _currentMessage,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary, // Uses the primary color from the theme.
                  ),
              textAlign: TextAlign.center, // Centers text if it wraps to multiple lines.
            ),
            const SizedBox(height: 32), // Provides vertical spacing between the text and the button.
            // An elevated button to trigger the message change.
            ElevatedButton(
              onPressed: _toggleMessage, // Calls _toggleMessage when the button is pressed.
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Custom padding for the button.
                textStyle: const TextStyle(fontSize: 18), // Custom text style for the button's child.
              ),
              child: const Text('Toggle Message'), // Text displayed on the button.
            ),
          ],
        ),
      ),
      // A floating action button, typically used for a primary action on the screen.
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMessage, // Also calls _toggleMessage when this button is pressed.
        tooltip: 'Toggle Message', // Accessibility tooltip for the button.
        child: const Icon(Icons.refresh), // Icon displayed on the floating action button.
      ),
    );
  }
}
