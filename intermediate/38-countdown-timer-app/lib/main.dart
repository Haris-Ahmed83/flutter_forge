import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'dart:ui'; // For FontFeature.tabularFigures

void main() {
  runApp(const CountdownTimerApp());
}

class CountdownTimerApp extends StatelessWidget {
  const CountdownTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CountdownTimerHomePage(),
    );
  }
}

class CountdownTimerHomePage extends StatefulWidget {
  const CountdownTimerHomePage({super.key});

  @override
  State<CountdownTimerHomePage> createState() => _CountdownTimerHomePageState();
}

class _CountdownTimerHomePageState extends State<CountdownTimerHomePage> {
  Duration _initialDuration = const Duration(minutes: 5); // Total time set for the timer
  Duration _remainingDuration = const Duration(minutes: 5); // Time left
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isCompleted = false;

  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize input controllers with default duration values
    _minutesController.text = _initialDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
    _secondsController.text = _initialDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel any active timer to prevent memory leaks
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  /// Starts the countdown timer.
  void _startTimer() {
    if (_initialDuration.inSeconds <= 0) {
      _showSnackBar('Please set a duration greater than zero.');
      return;
    }

    // If timer was completed, reset it before starting a new one.
    if (_isCompleted) {
      _resetTimer();
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isCompleted = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingDuration.inSeconds <= 0) {
        timer.cancel(); // Stop the timer when it reaches zero
        setState(() {
          _isRunning = false;
          _isCompleted = true;
          _showSnackBar('Timer completed!');
          // Optionally play a sound or vibrate here to alert the user
        });
      } else {
        setState(() {
          _remainingDuration = _remainingDuration - const Duration(seconds: 1);
        });
      }
    });
  }

  /// Pauses the countdown timer.
  void _pauseTimer() {
    _timer?.cancel(); // Stop the periodic timer
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
  }

  /// Resets the countdown timer to its initial set duration.
  void _resetTimer() {
    _timer?.cancel(); // Stop any active timer
    setState(() {
      _remainingDuration = _initialDuration;
      _isRunning = false;
      _isPaused = false;
      _isCompleted = false;
    });
  }

  /// Sets a new initial duration based on user input from text fields.
  void _setNewTimerDuration() {
    final int minutes = int.tryParse(_minutesController.text) ?? 0;
    final int seconds = int.tryParse(_secondsController.text) ?? 0;

    // Validate input values
    if (minutes < 0 || seconds < 0 || seconds >= 60) {
      _showSnackBar('Invalid time input. Minutes must be non-negative, seconds between 0-59.');
      return;
    }

    final Duration newDuration = Duration(minutes: minutes, seconds: seconds);

    if (newDuration.inSeconds <= 0) {
      _showSnackBar('Total duration must be greater than zero.');
      return;
    }

    _timer?.cancel(); // Cancel any active timer before setting a new one
    setState(() {
      _initialDuration = newDuration;
      _remainingDuration = newDuration;
      _isRunning = false;
      _isPaused = false;
      _isCompleted = false;
    });
    _showSnackBar('Timer set to ${newDuration.inMinutes}m ${newDuration.inSeconds.remainder(60)}s');
  }

  /// Shows a brief message at the bottom of the screen.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Formats the duration into HH:MM:SS string.
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    final String hours = twoDigits(duration.inHours);
    return '$hours:$minutes:$seconds';
  }

  /// Determines the background color for the AnimatedContainer based on remaining time percentage.
  /// Transitions smoothly from green (100%) to yellow (50%) to red (0%).
  Color _getAnimatedContainerColor() {
    if (_initialDuration.inSeconds == 0) {
      return Colors.grey.shade800; // Default color if no duration is set or duration is zero
    }

    final double percentage = _remainingDuration.inSeconds / _initialDuration.inSeconds;

    if (percentage > 0.5) {
      // Transition from yellow to green (as percentage goes from 0.5 to 1.0)
      // We normalize the percentage for this segment: (percentage - 0.5) * 2 ranges from 0 to 1.
      return Color.lerp(Colors.yellow, Colors.green.shade700, (percentage - 0.5) * 2) ?? Colors.green.shade700;
    } else if (percentage > 0) {
      // Transition from red to yellow (as percentage goes from 0 to 0.5)
      // We normalize the percentage for this segment: percentage * 2 ranges from 0 to 1.
      return Color.lerp(Colors.red.shade700, Colors.yellow, percentage * 2) ?? Colors.yellow;
    } else {
      // Timer completed or 0% remaining
      return Colors.red.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // Calculate the color for the AnimatedContainer based on current timer state
    final Color containerColor = _getAnimatedContainerColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown Timer'),
        backgroundColor: colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer Input Fields Section
            Text(
              'Set Timer Duration',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    // Allow only digits for input
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Minutes',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      hintText: '0-59',
                    ),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Seconds',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      hintText: '0-59',
                    ),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              // Disable button if timer is currently running or paused to prevent accidental resets
              onPressed: _isRunning || _isPaused ? null : _setNewTimerDuration,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Set Timer', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 48),

            // Animated Timer Display Section
            AnimatedContainer(
              duration: const Duration(milliseconds: 500), // Duration for the color animation
              curve: Curves.easeInOut, // Easing curve for a smooth transition
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: containerColor, // The dynamically changing background color
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                _formatDuration(_remainingDuration),
                style: theme.textTheme.displayLarge?.copyWith(
                  color: Colors.white, // Ensures text is readable on various background colors
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()], // Keeps numbers fixed width for better readability
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Control Buttons Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : (_isPaused ? 'Resume' : 'Start')),
                  heroTag: 'playPauseBtn', // Unique tag for multiple FloatingActionButtons
                ),
                const SizedBox(width: 24),
                FloatingActionButton.extended(
                  // Enable reset only if timer is running, paused, or completed
                  onPressed: _isRunning || _isPaused || _isCompleted ? _resetTimer : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  heroTag: 'resetBtn', // Unique tag for multiple FloatingActionButtons
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
