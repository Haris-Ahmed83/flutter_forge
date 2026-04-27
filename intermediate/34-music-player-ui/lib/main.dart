import 'dart:async'; // Required for Timer

import 'package:flutter/material.dart';

// --- Data Models ---

/// Represents a single song with its basic metadata.
class Song {
  final String title;
  final String artist;
  final String albumArtUrl; // URL for the album cover image

  const Song({
    required this.title,
    required this.artist,
    required this.albumArtUrl,
  });
}

// --- Main Application ---

void main() {
  runApp(const MusicPlayerApp());
}

/// The root widget of the application.
class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player UI',
      debugShowCheckedModeBanner: false, // Hide the debug banner
      theme: ThemeData(
        // Use Material 3 design system
        useMaterial3: true,
        // Define a dark color scheme for a modern music player feel
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Primary seed color for the theme
          brightness: Brightness.dark, // Set overall theme brightness to dark
        ),
        // Customize app bar theme for a consistent look
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0, // No shadow for a flat, modern look
        ),
      ),
      home: const MusicPlayerScreen(),
    );
  }
}

// --- Music Player Screen ---

/// The main screen displaying the music player interface.
class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  // Sample song data to display
  final Song _currentSong = const Song(
    title: 'Flutter Flow',
    artist: 'Dart & The Widgets',
    albumArtUrl: 'https://picsum.photos/id/1047/400/400', // Placeholder image URL
  );

  // --- Playback State Variables ---
  bool _isPlaying = false; // True if the song is currently playing
  double _currentPosition = 0.0; // Current playback position in seconds
  double _totalDuration = 240.0; // Total song duration in seconds (e.g., 4 minutes)
  double _volume = 0.7; // Volume level (0.0 to 1.0)
  bool _isShuffling = false; // True if shuffle mode is active
  bool _isRepeating = false; // True if repeat mode is active

  Timer? _playbackTimer; // Timer to simulate song progress

  @override
  void initState() {
    super.initState();
    // Initialize current position to 0 when the screen starts
    _currentPosition = 0.0;
  }

  /// Starts or resumes the playback simulation timer.
  /// In a real application, this would interact with an audio playback package
  /// (e.g., `just_audio`, `audioplayers`) to update the position.
  void _startPlaybackTimer() {
    _playbackTimer?.cancel(); // Cancel any existing timer to avoid duplicates

    // Create a new periodic timer that updates every 500 milliseconds
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isPlaying || _currentPosition >= _totalDuration) {
        // If not playing or song has ended, stop the timer
        timer.cancel();
        if (_currentPosition >= _totalDuration) {
          setState(() {
            _isPlaying = false; // Set playing state to false
            _currentPosition = _totalDuration; // Ensure position doesn't exceed duration
          });
        }
        return;
      }
      setState(() {
        _currentPosition += 0.5; // Increment position by 0.5 seconds
      });
    });
  }

  /// Toggles the play/pause state of the song.
  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying && _currentPosition < _totalDuration) {
        _startPlaybackTimer(); // Start or resume playback simulation
      } else {
        _playbackTimer?.cancel(); // Pause the simulation
      }
    });
    // TODO: In a real app, call audioPlayer.play() or audioPlayer.pause()
  }

  /// Formats a duration in seconds into a "MM:SS" string.
  String _formatDuration(double seconds) {
    final int minutes = (seconds ~/ 60); // Integer division for minutes
    final int remainingSeconds = (seconds % 60).toInt(); // Remainder for seconds
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _playbackTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the current theme's color scheme for consistent styling
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
        leading: IconButton(
          // Icon for minimizing or navigating back
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onPressed: () {
            // TODO: Implement navigation back or minimize player functionality
          },
        ),
        actions: [
          IconButton(
            // Icon for more options menu
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement more options menu (e.g., add to playlist, view lyrics)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- Album Art Display ---
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0), // Rounded corners for album art
                child: Image.network(
                  _currentSong.albumArtUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  // Show a loading indicator while the image is fetching
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: colorScheme.primary,
                      ),
                    );
                  },
                  // Show a fallback icon if image fails to load
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.music_note,
                      size: 100,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0), // Spacing below album art

            // --- Song Information (Title and Artist) ---
            Column(
              children: [
                Text(
                  _currentSong.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Truncate long titles
                ),
                const SizedBox(height: 8.0),
                Text(
                  _currentSong.artist,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Truncate long artists
                ),
              ],
            ),
            const SizedBox(height: 32.0), // Spacing below song info

            // --- Playback Progress Slider (Key Concept: Slider) ---
            Column(
              children: [
                Slider(
                  // Clamp value to ensure it stays within min/max bounds
                  value: _currentPosition.clamp(0.0, _totalDuration),
                  min: 0.0,
                  max: _totalDuration,
                  onChanged: (newValue) {
                    setState(() {
                      _currentPosition = newValue; // Update position when user drags slider
                    });
                    // TODO: In a real app, seek the audio to this new position
                  },
                  activeColor: colorScheme.primary, // Color for the active part of the slider
                  inactiveColor: colorScheme.onSurface.withOpacity(0.3), // Inactive part color
                  thumbColor: colorScheme.primary, // Color of the slider thumb
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Display current formatted playback time
                      Text(
                        _formatDuration(_currentPosition),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      // Display total formatted song duration
                      Text(
                        _formatDuration(_totalDuration),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0), // Spacing below progress slider

            // --- Playback Controls (Key Concept: Icons) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Shuffle button
                IconButton(
                  icon: Icon(
                    // Toggle icon based on shuffle state
                    _isShuffling ? Icons.shuffle_on_rounded : Icons.shuffle_rounded,
                    color: _isShuffling
                        ? colorScheme.primary // Active color if shuffling
                        : colorScheme.onSurfaceVariant, // Inactive color
                  ),
                  iconSize: 28.0,
                  onPressed: () {
                    setState(() {
                      _isShuffling = !_isShuffling; // Toggle shuffle state
                    });
                    // TODO: Implement actual shuffle logic for playlist
                  },
                ),
                // Skip previous button
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded),
                  iconSize: 48.0,
                  onPressed: () {
                    // TODO: Implement skip to previous song logic
                  },
                ),
                // Play/Pause button
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary, // Background color for the button
                    shape: BoxShape.circle, // Circular shape
                  ),
                  child: IconButton(
                    icon: Icon(
                      // Toggle icon based on playback state
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: colorScheme.onPrimary, // Icon color
                    ),
                    iconSize: 64.0,
                    onPressed: _togglePlayPause, // Call play/pause function
                  ),
                ),
                // Skip next button
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: 48.0,
                  onPressed: () {
                    // TODO: Implement skip to next song logic
                  },
                ),
                // Repeat button
                IconButton(
                  icon: Icon(
                    // Toggle icon based on repeat state
                    _isRepeating ? Icons.repeat_on_rounded : Icons.repeat_rounded,
                    color: _isRepeating
                        ? colorScheme.primary // Active color if repeating
                        : colorScheme.onSurfaceVariant, // Inactive color
                  ),
                  iconSize: 28.0,
                  onPressed: () {
                    setState(() {
                      _isRepeating = !_isRepeating; // Toggle repeat state
                    });
                    // TODO: Implement actual repeat logic (e.g., repeat one, repeat all)
                  },
                ),
              ],
            ),
            const SizedBox(height: 24.0), // Spacing below playback controls

            // --- Volume Slider (Key Concept: Slider) ---
            Row(
              children: [
                Icon(Icons.volume_down_rounded, color: colorScheme.onSurfaceVariant),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (newValue) {
                      setState(() {
                        _volume = newValue; // Update volume when user drags slider
                      });
                      // TODO: Set actual audio volume using an audio package
                    },
                    activeColor: colorScheme.onSurfaceVariant,
                    inactiveColor: colorScheme.onSurface.withOpacity(0.2),
                    thumbColor: colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(Icons.volume_up_rounded, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
