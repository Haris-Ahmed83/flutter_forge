import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Counter App',
      theme: ThemeData(
        // Define a Material 3 color scheme from a seed color.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Enable Material 3 design features.
      ),
      home: const MyHomePage(title: 'Flutter Counter Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0; // The current counter value, initialized to 0.

  // Method to increment the counter.
  void _incrementCounter() {
    // setState notifies the Flutter framework that the internal state of this
    // object has changed, which causes it to reschedule a build of this widget.
    setState(() {
      _counter++;
    });
  }

  // Method to decrement the counter.
  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  // Method to reset the counter to 0.
  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the current theme's text styles for consistent typography.
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        // AppBar background color derived from the Material 3 color scheme.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically within the column.
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
              style: textTheme.titleMedium, // Using a Material 3 text style for descriptive text.
            ),
            const SizedBox(height: 16), // Spacing between text elements.
            Text(
              '$_counter', // Display the current counter value.
              style: textTheme.displayLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary, // Custom color for the counter text.
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32), // More spacing before the buttons.
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center buttons horizontally within the row.
              children: <Widget>[
                // ElevatedButton for decrementing the counter.
                ElevatedButton.icon(
                  onPressed: _decrementCounter, // Callback function when the button is pressed.
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrement'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 24), // Spacing between buttons.
                // ElevatedButton for incrementing the counter.
                ElevatedButton.icon(
                  onPressed: _incrementCounter, // Callback function when the button is pressed.
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // FloatingActionButton to reset the counter.
      floatingActionButton: FloatingActionButton(
        onPressed: _resetCounter, // Callback function to reset the counter.
        tooltip: 'Reset Counter',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
