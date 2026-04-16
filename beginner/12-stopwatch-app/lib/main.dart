import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui'; // Required for FontFeature.tabularFigures

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch App',
      // Enable Material 3 design with a consistent color scheme seed
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple, // A vibrant base color for the app
        useMaterial3: true,
        brightness: Brightness.light, // Default to light mode
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark, // Support dark mode
      ),
      themeMode: ThemeMode.system, // Respect the user's system theme preference
      home: const StopwatchPage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner in release mode
    );
  }
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch(); // The core Stopwatch object
  Timer? _timer; // Timer to periodically update the UI
  final StreamController<int> _streamController =
      StreamController<int>(); // Stream to push elapsed milliseconds to the UI
  bool _isRunning = false; // Flag to track if the stopwatch is currently active
  final List<Duration> _laps = []; // List to store recorded lap times

  @override
  void initState() {
    super.initState();
    // Initialize the stream with 0 milliseconds when the widget first loads,
    // ensuring the display shows "00:00:00.000" initially.
    _streamController.add(0);
  }

  // Starts the stopwatch and begins emitting time updates to the stream.
  void _startStopwatch() {
    setState(() {
      _isRunning = true; // Update UI to reflect running state
    });
    _stopwatch.start(); // Start the native Stopwatch
    // Use a periodic Timer to update the display frequently.
    // A duration of 30ms provides a smooth update without excessive CPU usage.
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      // Add the current elapsed milliseconds to the stream,
      // which will trigger StreamBuilder to rebuild.
      _streamController.add(_stopwatch.elapsedMilliseconds);
    });
  }

  // Stops the stopwatch and pauses time updates.
  void _stopStopwatch() {
    setState(() {
      _isRunning = false; // Update UI to reflect paused state
    });
    _stopwatch.stop(); // Stop the native Stopwatch
    _timer?.cancel(); // Cancel the periodic timer to stop updates
  }

  // Resets the stopwatch to zero and clears all recorded laps.
  void _resetStopwatch() {
    _stopStopwatch(); // Ensure the stopwatch is stopped before resetting
    _stopwatch.reset(); // Reset the native Stopwatch to 0
    _streamController.add(0); // Emit 0 to instantly update the display to zero
    setState(() {
      _laps.clear(); // Clear all previously recorded lap times
    });
  }

  // Records the current elapsed time as a new lap.
  void _recordLap() {
    setState(() {
      _laps.add(_stopwatch.elapsed); // Add the current elapsed duration to the laps list
    });
  }

  // Helper function to format a duration from milliseconds into HH:MM:SS.ms string.
  String _formatDuration(int milliseconds) {
    final Duration duration = Duration(milliseconds: milliseconds);
    // Helper to ensure numbers are always two digits (e.g., 5 becomes "05")
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    // Helper to ensure milliseconds are always three digits (e.g., 50 becomes "050")
    String threeDigits(int n) => n.toString().padLeft(3, '0');

    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String ms = threeDigits(duration.inMilliseconds.remainder(1000));

    return "$hours:$minutes:$seconds.$ms";
  }

  @override
  void dispose() {
    _timer?.cancel(); // Important: Cancel the timer to prevent memory leaks
    _streamController.close(); // Important: Close the stream controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the current theme's color scheme and text theme for consistent styling.
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        backgroundColor: colorScheme.primaryContainer, // AppBar background color
        foregroundColor: colorScheme.onPrimaryContainer, // AppBar text/icon color
        elevation: 0, // No shadow under the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Overall padding for the body content
        child: Column(
          children: [
            // Main display for the stopwatch time, updated via StreamBuilder.
            StreamBuilder<int>(
              stream: _streamController.stream, // Listen to the stream of elapsed milliseconds
              builder: (context, snapshot) {
                // If no data yet (e.g., initial state), default to 0 milliseconds.
                final int elapsedMilliseconds = snapshot.data ?? 0;
                return Text(
                  _formatDuration(elapsedMilliseconds), // Format milliseconds into readable string
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    // Use tabular figures for consistent number alignment,
                    // preventing UI "jumps" as digits change.
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
            const SizedBox(height: 48.0), // Spacing below the time display
            // Row for control buttons (Reset, Start/Pause, Lap)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
              children: [
                // Reset Button
                ElevatedButton.icon(
                  // Disable if stopwatch is already at zero and not running
                  onPressed: (_stopwatch.elapsedMilliseconds == 0 && !_isRunning)
                      ? null
                      : _resetStopwatch,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer, // Distinct color for reset
                    foregroundColor: colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: textTheme.titleMedium,
                  ),
                ),
                // Start/Pause Button
                ElevatedButton.icon(
                  onPressed: _isRunning ? _stopStopwatch : _startStopwatch, // Toggle start/stop
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow), // Icon changes with state
                  label: Text(_isRunning ? 'Pause' : 'Start'), // Text changes with state
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? colorScheme.tertiaryContainer : colorScheme.primary,
                    foregroundColor: _isRunning ? colorScheme.onTertiaryContainer : colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: textTheme.titleMedium,
                  ),
                ),
                // Lap Button
                ElevatedButton.icon(
                  onPressed: _isRunning ? _recordLap : null, // Only enabled when stopwatch is running
                  icon: const Icon(Icons.flag),
                  label: const Text('Lap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer, // Distinct color for lap
                    foregroundColor: colorScheme.onSecondaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0), // Spacing below buttons
            // Display for lap times
            Expanded(
              child: _laps.isEmpty
                  ?
