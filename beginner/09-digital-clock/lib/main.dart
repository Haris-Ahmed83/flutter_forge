import 'dart:async'; // Required for Timer
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Base color for Material 3
          brightness: Brightness.dark, // Dark theme for a modern clock look
        ),
        useMaterial3: true,
        // Custom text styles for the clock display using a monospaced font
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'RobotoMono', // Monospaced font for a digital feel
            fontSize: 96,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          displayMedium: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 48,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 32,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      home: const DigitalClockScreen(),
    );
  }
}

class DigitalClockScreen extends StatefulWidget {
  const DigitalClockScreen({super.key});

  @override
  State<DigitalClockScreen> createState() => _DigitalClockScreenState();
}

class _DigitalClockScreenState extends State<DigitalClockScreen> {
  DateTime _currentTime = DateTime.now(); // Stores the current time
  late Timer _timer; // Timer to update the clock every second

  @override
  void initState() {
    super.initState();
    // Initialize the timer to periodically update the time.
    // Timer.periodic calls the callback function every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    // setState triggers a rebuild of the widget, updating the displayed time.
    setState(() {
      _currentTime = DateTime.now();
    });
  }

  @override
  void dispose() {
    // It's crucial to cancel the timer when the widget is disposed
    // to prevent memory leaks and unnecessary background activity.
    _timer.cancel();
    super.dispose();
  }

  // Helper method to format numbers with a leading zero if less than 10.
  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    // Get current hour, minute, second from the DateTime object
    int hour = _currentTime.hour;
    final int minute = _currentTime.minute;
    final int second = _currentTime.second;

    // Determine AM/PM and convert to 12-hour format
    final String amPm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12; // Converts 13-23 to 1-11, and 0 to 0
    if (hour == 0) hour = 12; // Converts 0 (midnight) to 12 for 12-hour display

    // Format the time components with leading zeros
    final String formattedHour = _formatNumber(hour);
    final String formattedMinute = _formatNumber(minute);
    final String formattedSecond = _formatNumber(second);

    // Get text theme and display color from the current theme for consistency
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color displayColor = Theme.of(context).colorScheme.onBackground;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Clock'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display HH:MM in a large, prominent style
            Text(
              '$formattedHour:$formattedMinute',
              style: textTheme.displayLarge?.copyWith(color: displayColor),
            ),
            const SizedBox(height: 8), // Spacing between HH:MM and SS/AMPM
            // Display SS and AM/PM in a slightly smaller, secondary style
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic, // Align text baselines
              children: <Widget>[
                Text(
                  formattedSecond,
                  style: textTheme.displayMedium?.copyWith(color: displayColor.withOpacity(0.7)),
                ),
                const SizedBox(width: 16), // Spacing between SS and AM/PM
                Text(
                  amPm,
                  style: textTheme.headlineMedium?.copyWith(color: displayColor.withOpacity(0.7)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
