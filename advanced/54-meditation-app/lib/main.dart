import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Audio playback
import 'dart:ui'; // For FontFeature.tabularFigures

// TODO: Add audioplayers to your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   audioplayers: ^5.2.1 // Or the latest stable version

// TODO: Create an 'assets' folder in your project root.
// Inside 'assets', create an 'audio' folder and an 'images' folder.
// Place some royalty-free audio files (e.g., .mp3) in 'assets/audio'.
// Place some royalty-free image files (e.g., .jpg, .png) in 'assets/images'.
// Update pubspec.yaml to include assets:
// flutter:
//   uses-material-design: true
//   assets:
//     - assets/audio/calm_forest.mp3
//     - assets/audio/ocean_waves.mp3
//     - assets/audio/rain_sound.mp3
//     - assets/images/meditation_bg1.jpg
//     - assets/images/meditation_bg2.jpg
//     - assets/images/meditation_bg3.jpg
// You can use placeholder images and audio if you don't have real ones.
// For example, download some free ones from Pixabay or Pexels.

void main() {
  runApp(const MeditationApp());
}

/// Represents a single meditation session with its details.
class Meditation {
  final String id;
  final String title;
  final String description;
  final int durationMinutes; // Duration in minutes
  final String audioAssetPath;
  final String imageAssetPath;

  const Meditation({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.audioAssetPath,
    required this.imageAssetPath,
  });
}

/// Sample meditation data.
final List<Meditation> meditations = [
  Meditation(
    id: '1',
    title: 'Mindfulness Breath',
    description: 'Focus on your breath and find inner peace.',
    durationMinutes: 10,
    audioAssetPath: 'assets/audio/calm_forest.mp3',
    imageAssetPath: 'assets/images/meditation_bg1.jpg',
  ),
  Meditation(
    id: '2',
    title: 'Ocean Waves Relaxation',
    description: 'Let the gentle waves wash away your stress.',
    durationMinutes: 15,
    audioAssetPath: 'assets/audio/ocean_waves.mp3',
    imageAssetPath: 'assets/images/meditation_bg2.jpg',
  ),
  Meditation(
    id: '3',
    title: 'Focus & Concentration',
    description: 'Improve your focus with guided meditation.',
    durationMinutes: 20,
    audioAssetPath: 'assets/audio/rain_sound.mp3',
    imageAssetPath: 'assets/images/meditation_bg3.jpg',
  ),
  Meditation(
    id: '4',
    title: 'Deep Sleep Journey',
    description: 'Prepare your mind and body for restful sleep.',
    durationMinutes: 30,
    audioAssetPath: 'assets/audio/calm_forest.mp3', // Reusing audio
    imageAssetPath: 'assets/images/meditation_bg1.jpg', // Reusing image
  ),
];

/// The root widget of the Meditation App.
class MeditationApp extends StatelessWidget {
  const MeditationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditation App',
      theme: ThemeData(
        brightness: Brightness.dark, // Dark theme for a calming effect
        colorSchemeSeed: Colors.deepPurple, // A soothing primary color
        useMaterial3: true,
        fontFamily: 'Roboto', // Modern font
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          // Defined for Material 3's typography scale
          displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ),
      home: const HomePage(),
    );
  }
}

/// The home page displaying a list of available meditation sessions.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meditate & Relax',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Choose your meditation session',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two items per row
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8, // Adjust aspect ratio for card height
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final meditation = meditations[index];
                  return MeditationCard(meditation: meditation);
                },
                childCount: meditations.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16.0)),
        ],
      ),
    );
  }
}

/// A card widget to display a single meditation session on the home page.
class MeditationCard extends StatelessWidget {
  final Meditation meditation;
  const MeditationCard({super.key, required this.meditation});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias, // Clip children to card shape
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MeditationSessionPage(meditation: meditation),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'meditation-image-${meditation.id}', // Unique tag for Hero animation
                child: Image.asset(
                  meditation.imageAssetPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colorScheme.surfaceVariant,
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image,
                        color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meditation.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meditation.durationMinutes} min',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.play_circle_fill,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page for an active meditation session, featuring timer, audio, and animations.
class MeditationSessionPage extends StatefulWidget {
  final Meditation meditation;
  const MeditationSessionPage({super.key, required this.meditation});

  @override
  State<MeditationSessionPage> createState() => _MeditationSessionPageState();
}

class _MeditationSessionPageState extends State<MeditationSessionPage>
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer; // Audio player instance
  late AnimationController _breathingAnimationController; // Controls breathing animation
  late Animation<double> _breathingScaleAnimation; // Scale animation for breathing
  Timer? _timer; // Countdown timer for the session
  int _remainingSeconds = 0; // Remaining time in seconds
  bool _isPlaying = false; // Whether the meditation is currently playing
  bool _isSessionFinished = false; // Flag to indicate if session is finished

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.meditation.durationMinutes * 60; // Initialize remaining time
    _audioPlayer = AudioPlayer(); // Create a new audio player
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop audio by default

    // Initialize breathing animation controller
    _breathingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Breathing cycle duration
    )..repeat(reverse: true); // Repeat animation reversing direction

    // Define the scale animation: 0.8 (contracted) to 1.2 (expanded)
    _breathingScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _breathingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Listen for audio player state changes (e.g., completion, error)
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        // Additional state handling can be added here if needed
        // For example, if audio stops unexpectedly, handle it.
      }
    });

    // Start playing audio and timer immediately
    _playMeditation();
  }

  /// Plays the meditation audio and starts the countdown timer.
  void _playMeditation() async {
    if (_isSessionFinished) return; // Don't play if session is already finished

    setState(() {
      _isPlaying = true;
    });

    try {
      // Play audio from assets
      await _audioPlayer.setSourceAsset(widget.meditation.audioAssetPath);
      await _audioPlayer.resume(); // Start or resume audio playback
    } catch (e) {
      // Handle potential errors during audio playback (e.g., file not found)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error playing audio: $e. Check asset path.')),
        );
        _stopMeditation(); // Stop the session if audio fails
        return;
      }
    }
    _breathingAnimationController.forward(); // Start breathing animation

    // Start a periodic timer that fires every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel(); // Cancel timer if widget is no longer in tree
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel(); // Cancel timer when countdown reaches zero
          _audioPlayer.stop(); // Stop audio
          _breathingAnimationController.stop(); // Stop breathing animation
          _isPlaying = false;
          _isSessionFinished = true;
          _showCompletionDialog(); // Show completion message
        }
      });
    });
  }

  /// Pauses the meditation audio and timer.
  void _pauseMeditation() {
    _timer?.cancel(); // Cancel the countdown timer
    _audioPlayer.pause(); // Pause audio playback
    _breathingAnimationController.stop(); // Stop breathing animation
    setState(() {
      _isPlaying = false;
    });
  }

  /// Stops the meditation, resets the timer, and navigates back.
  void _stopMeditation() {
    _timer?.cancel(); // Cancel the timer
    _audioPlayer.stop(); // Stop audio playback
    _breathingAnimationController.reset(); // Reset animation
    _isPlaying = false;
    _isSessionFinished = false; // Reset session finished flag
    if (mounted) {
      Navigator.pop(context); // Go back to the home page
    }
  }

  /// Shows a dialog when the meditation session is completed.
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Completed!'),
          content: Text(
            'You have successfully completed your ${widget.meditation.title} session.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Great!'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                Navigator.of(context).pop(); // Go back to home page
              },
            ),
          ],
        );
      },
    );
  }

  /// Formats remaining seconds into a MM:SS string.
  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel(); // Ensure timer is cancelled
    _audioPlayer.dispose(); // Release audio player resources
    _breathingAnimationController.dispose(); // Dispose animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true, // AppBar is transparent, body extends behind
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: _stopMeditation, // Use stop to return
        ),
        actions: [
          // Optional: Volume control or settings can be added here
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              // TODO: Implement volume control functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Volume control not implemented yet.')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Hero(
              tag: 'meditation-image-${widget.meditation.id}',
              child: Image.asset(
                widget.meditation.imageAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image,
                      color: colorScheme.onSurfaceVariant, size: 48),
                ),
              ),
            ),
          ),
          // Gradient Overlay for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Meditation Title
                Text(
                  widget.meditation.title,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Breathing Animation
                AnimatedBuilder(
                  animation: _breathingScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _breathingScaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withOpacity(0.4),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.spa_outlined, // Breathing icon
                          color: Colors.white.withOpacity(0.9),
                          size: 70,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Timer Display
                Text(
                  _formatTime(_remainingSeconds),
                  style: textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontFeatures: const [
                      FontFeature.tabularFigures()
                    ], // For fixed-width numbers
                  ),
                ),
                const SizedBox(height: 32),
                // Progress Indicator (Circular)
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 1 -
                            (_remainingSeconds /
                                (widget.meditation.durationMinutes * 60)),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        strokeWidth: 8,
                      ),
                      Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                // Play/Pause and Stop Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 64,
                      color: Colors.white,
                      onPressed: _isSessionFinished
                          ? null // Disable if session is finished
                          : (_isPlaying ? _pauseMeditation : _playMeditation),
                      icon: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      iconSize: 64,
                      color: Colors.white,
                      onPressed: _isSessionFinished ? null : _stopMeditation,
                      icon: const Icon(Icons.stop_circle_filled),
                    ),
                  ],
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
