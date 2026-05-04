import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemChrome to manage fullscreen and orientation
import 'package:video_player/video_player.dart';

// --- 1. Main Application Setup ---

void main() {
  // Ensure Flutter widgets are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred device orientations (e.g., portrait only for the app initially).
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Stream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // --- 2. Material 3 Design ---
        // Define a dark color scheme suitable for a video streaming app.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          // Customizing some colors for a sleek look.
          primary: Colors.deepPurpleAccent,
          onPrimary: Colors.white,
          surface: const Color(0xFF121212),
          onSurface: Colors.white,
          background: const Color(0xFF121212),
          onBackground: Colors.white,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Transparent app bar for a modern look.
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E), // Darker card background.
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 4,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white54),
        ),
        sliderTheme: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay, // No overlay for a cleaner look.
          trackHeight: 3.0,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// --- 3. Sample Data Model ---

/// Represents a single video with its metadata.
class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String description;

  const Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.description = 'A captivating video for your enjoyment.',
  });
}

// Sample video data for demonstration.
const List<Video> sampleVideos = [
  Video(
    id: '1',
    title: 'Flutter Demo Video',
    thumbnailUrl: 'https://cdn.pixabay.com/photo/2016/11/29/05/45/camera-1867162_960_720.jpg',
    videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    description: 'A short demo video showcasing the capabilities of the Flutter video player.',
  ),
  Video(
    id: '2',
    title: 'Big Buck Bunny Trailer',
    thumbnailUrl: 'https://peach.blender.org/wp-content/uploads/title_sm.jpg?x11217',
    videoUrl: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    description: 'Big Buck Bunny is a 2008 short computer-animated comedy film by the Blender Institute.',
  ),
  Video(
    id: '3',
    title: 'Sintel Trailer',
    thumbnailUrl: 'https://durian.blender.org/wp-content/uploads/sintel_poster_small.jpg',
    videoUrl: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    description: 'Sintel is a 2010 Dutch computer-animated fantasy short film.',
  ),
  Video(
    id: '4',
    title: 'Tears of Steel Trailer',
    thumbnailUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e3/Tears_of_Steel_poster.jpg',
    videoUrl: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    description: 'Tears of Steel (code-named Project Mango) is a 2012 Dutch science fiction short film.',
  ),
];

// --- 4. Home Page (Main Screen) ---

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  VideoPlayerController? _controller;
  Video? _currentVideo;
  bool _isPlayerReady = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _currentVideo = sampleVideos.first; // Load the first video by default.
    _initializeVideoPlayer(_currentVideo!);
  }

  /// Initializes or changes the video player with a new video.
  Future<void> _initializeVideoPlayer(Video video) async {
    _isPlayerReady = false;
    if (_controller != null) {
      await _controller!.dispose(); // Dispose previous controller to free resources.
    }

    _controller = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl))
      ..addListener(() {
        if (mounted) {
          setState(() {}); // Rebuild UI on controller updates (e.g., position, buffering).
        }
      })
      ..setLooping(true); // Loop the video for continuous playback.

    try {
      await _controller!.initialize();
      setState(() {
        _isPlayerReady = true;
        _controller!.play(); // Auto-play the video after initialization.
      });
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      setState(() {
        // Handle initialization errors, e.g., show an error message to the user.
        _isPlayerReady = false;
      });
    }
  }

  /// Toggles fullscreen mode for the video player.
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      // Enter fullscreen: hide system UI (status bar, navigation bar) and set landscape orientation.
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Exit fullscreen: show system UI and set portrait orientation.
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose the video controller to prevent memory leaks.
    // Reset system UI and orientation preferences when the widget is disposed.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _isFullScreen
          ? null // Hide app bar in fullscreen mode.
          : AppBar(
              title: const Text('Video Stream'),
              backgroundColor: Theme.of(context).colorScheme.background,
            ),
      body: Column(
        children: [
          // --- Video Player Area ---
          AspectRatio(
            aspectRatio: _controller?.value.aspectRatio ?? 16 / 9, // Use controller's aspect ratio or default.
            child: _isPlayerReady && _controller != null
                ? VideoPlayerView(
                    controller: _controller!,
                    isFullScreen: _isFullScreen,
                    onToggleFullScreen: _toggleFullScreen,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _currentVideo?.title ?? 'Loading Video...',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
          ),
          if (!_isFullScreen) // Don't show the video list in fullscreen mode.
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: sampleVideos.length,
                itemBuilder: (context, index) {
                  final video = sampleVideos[index];
                  return VideoListItem(
                    video: video,
                    onTap: (selectedVideo) {
                      setState(() {
                        _currentVideo = selectedVideo; // Update the currently playing video.
                      });
                      _initializeVideoPlayer(selectedVideo); // Load and play the new video.
                    },
                    isSelected: _currentVideo?.id == video.id, // Highlight the currently playing video.
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// --- 5. Video Player View with Custom Controls ---

class VideoPlayerView extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const VideoPlayerView({
    super.key,
    required this.controller,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  bool _controlsVisible = true;
  bool _isBuffering = false;
  // Timer for automatically hiding controls after inactivity.
  Future<void>? _hideControlsFuture;

  @override
  void initState() {
    super.initState();
    _startHideControlsTimer(); // Start timer to hide controls after initial display.
    widget.controller.addListener(_videoListener); // Listen to video controller changes.
  }

  @override
  void didUpdateWidget(covariant VideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_videoListener);
      widget.controller.addListener(_videoListener);
      // Reset controls visibility and timer when the video controller changes (e.g., new video loaded).
      _controlsVisible = true;
      _startHideControlsTimer();
    }
  }

  // Listener for video controller events, primarily used to update buffering state.
  void _videoListener() {
    if (!mounted) return;
    final bool isBuffering = widget.controller.value.isBuffering;
    if (_isBuffering != isBuffering) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }
    // If video ends, show controls for replay.
    if (widget.controller.value.position >= widget.controller.value.duration && widget.controller.value.duration != Duration.zero) {
      setState(() {
        _controlsVisible = true;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    _hideControlsFuture = null; // Cancel any pending timer to avoid calling setState on a disposed widget.
    super.dispose();
  }

  /// Toggles the visibility of the video controls.
  void _toggleControlsVisibility() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _startHideControlsTimer(); // Restart timer if controls are shown.
    } else {
      _hideControlsFuture = null; // Cancel timer if controls are manually hidden.
    }
  }

  /// Starts a timer to hide the controls after a delay if no interaction occurs.
  void _startHideControlsTimer() {
    _hideControlsFuture?.ignore(); // Cancel any existing timer.
    _hideControlsFuture = Future.delayed(const Duration(seconds: 3), () {
      // Only hide controls if the widget is still mounted and controls are visible.
      // Do not hide if video is paused, as user might be interacting with controls.
      if (mounted && _controlsVisible && widget.controller.value.isPlaying) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  /// Formats a Duration object into a human-readable string (HH:MM:SS or MM:SS).
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if the controller is not yet initialized.
    if (!widget.controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _toggleControlsVisibility, // Tap anywhere on video to show/hide controls.
      child: ColoredBox(
        color: Colors.black, // Ensures a black background for the video player.
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(widget.controller),
            // Buffering indicator displayed when the video is buffering.
            if (_isBuffering)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            // Custom Controls Overlay
            AnimatedOpacity(
              opacity: _controlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AbsorbPointer(
                absorbing: !_controlsVisible, // Disable interaction when controls are hidden.
                child: Container(
                  color: Colors.black54, // Semi-transparent overlay for controls.
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top gradient for potential future controls (e.g., back button, title).
                      const SizedBox(height: 48), // Placeholder for top bar.
                      // Center Play/Pause button.
                      Expanded(
                        child: Center(
                          child: IconButton(
                            iconSize: 80.0,
                            color: Colors.white,
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              // Animate icon based on play/pause state.
                              progress: widget.controller.value.isPlaying
                                  ? CurvedAnimation(parent: const AlwaysStoppedAnimation(1), curve: Curves.easeOut)
                                  : CurvedAnimation(parent: const AlwaysStoppedAnimation(0), curve: Curves.easeIn),
                            ),
                            onPressed: () {
                              setState(() {
                                widget.controller.value.isPlaying
                                    ? widget.controller.pause()
                                    : widget.controller.play();
                              });
                              _startHideControlsTimer(); // Reset timer on interaction.
                            },
                          ),
                        ),
                      ),
                      // Bottom control bar with progress, time, and fullscreen button.
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Video Progress Indicator
                            VideoProgressIndicator(
                              widget.controller,
                              allowScrubbing: true, // Allow user to scrub through the video.
                              colors: VideoProgressColors(
                                playedColor: Theme.of(context).colorScheme.primary,
                                bufferedColor: Colors.white30,
                                backgroundColor: Colors.white10,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            Row(
                              children: [
                                Text(
                                  _formatDuration(widget.controller.value.position),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Text(' / ', style: TextStyle(color: Colors.white70)),
                                Text(
                                  _formatDuration(widget.controller.value.duration),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    widget.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    widget.onToggleFullScreen(); // Toggle fullscreen mode.
                                    _startHideControlsTimer(); // Reset timer on interaction.
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 6. Video List Item Widget ---

/// A widget to display a video's thumbnail, title, and description in a list.
class VideoListItem extends StatelessWidget {
  final Video video;
  final ValueChanged<Video> onTap;
  final bool isSelected;

  const VideoListItem({
    super.key,
    required this.video,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      // Change card color if the video is currently selected.
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : Theme.of(context).cardTheme.color,
      child: InkWell(
        onTap: () => onTap(video), // Callback when the item is tapped.
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  video.thumbnailUrl,
                  width: 120,
                  height: 70,
                  fit: BoxFit.cover,
                  // Placeholder for image loading errors.
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 120,
                    height: 70,
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, color: Colors.white54, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Colors.white,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      video.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7) : Colors.white70,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
