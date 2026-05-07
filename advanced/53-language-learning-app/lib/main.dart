import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For random card selection

/// IMPORTANT: Add the following to your pubspec.yaml before running:
/// dependencies:
///   flutter:
///     sdk: flutter
///   audioplayers: ^5.0.0 # Use the latest stable version
///   intl: ^0.18.0 # Use the latest stable version

void main() {
  runApp(const MyApp());
}

/// Enum to represent the outcome of reviewing a flashcard.
enum ReviewOutcome { hard, good, easy }

/// Represents a single flashcard with all necessary spaced repetition data.
class Flashcard {
  final String id;
  final String word;
  final String translation;
  final String? audioUrl; // URL for audio playback (can be local asset or network)
  DateTime lastReviewed;
  int repetitions; // Number of successful reviews
  double interval; // Current interval in days
  double easeFactor; // Factor to adjust interval (Anki-like algorithm)

  // Calculated property: When this card is due for review next.
  DateTime get nextReview => lastReviewed.add(Duration(days: interval.round()));

  Flashcard({
    required this.id,
    required this.word,
    required this.translation,
    this.audioUrl,
    DateTime? lastReviewed,
    this.repetitions = 0,
    this.interval = 0.0,
    this.easeFactor = 2.5, // Default Anki ease factor
  }) : lastReviewed = lastReviewed ?? DateTime.now();

  /// Updates the flashcard's spaced repetition parameters based on review outcome.
  void review(ReviewOutcome outcome) {
    lastReviewed = DateTime.now();

    switch (outcome) {
      case ReviewOutcome.hard:
        // Decrease ease factor, reset repetitions, set a short interval.
        easeFactor = max(1.3, easeFactor - 0.2); // Clamp ease factor at 1.3 minimum
        repetitions = 0;
        interval = 1.0; // Review again in 1 day
        break;
      case ReviewOutcome.good:
        // Increment repetitions, update interval based on current ease factor.
        repetitions++;
        if (repetitions == 1) {
          interval = 1.0; // First successful review, 1 day interval
        } else if (repetitions == 2) {
          interval = 6.0; // Second successful review, 6 day interval
        } else {
          interval *= easeFactor; // Subsequent reviews
        }
        break;
      case ReviewOutcome.easy:
        // Increase ease factor, increment repetitions, and set a longer interval.
        easeFactor = min(2.5, easeFactor + 0.1); // Clamp ease factor at 2.5 maximum
        repetitions++;
        if (repetitions == 1) {
          interval = 1.0;
        } else if (repetitions == 2) {
          interval = 6.0;
        } else {
          interval *= easeFactor * 1.3; // 30% longer than 'Good' for easy
        }
        break;
    }

    // Ensure interval is at least 1 day if it's not a brand new card (repetitions > 0).
    if (repetitions > 0 && interval < 1.0) {
      interval = 1.0;
    }
  }

  /// Creates a copy of the Flashcard with optional new values.
  Flashcard copyWith({
    String? id,
    String? word,
    String? translation,
    String? audioUrl,
    DateTime? lastReviewed,
    int? repetitions,
    double? interval,
    double? easeFactor,
  }) {
    return Flashcard(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      audioUrl: audioUrl ?? this.audioUrl,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      repetitions: repetitions ?? this.repetitions,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
    );
  }
}

/// A simple service to manage the list of flashcards.
/// In a real production app, this would typically interact with a database or API,
/// and use a state management solution like Provider or Riverpod.
class FlashcardService {
  // Using a static list to simulate persistent storage for the session
  // in this single-file example. Data will reset on app restart.
  static final List<Flashcard> _flashcards = [
    Flashcard(
      id: '1',
      word: 'Bonjour',
      translation: 'Hello',
      audioUrl: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3', // Placeholder audio URL
    ),
    Flashcard(
      id: '2',
      word: 'Merci',
      translation: 'Thank you',
      audioUrl: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    ),
    Flashcard(
      id: '3',
      word: 'Au revoir',
      translation: 'Goodbye',
      audioUrl: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    ),
    Flashcard(
      id: '4',
      word: 'Oui',
      translation: 'Yes',
      audioUrl: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    ),
    Flashcard(
      id: '5',
      word: 'Non',
      translation: 'No',
      audioUrl: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    ),
    Flashcard(
      id: '6',
      word: 'S\'il vous plaît',
      translation: 'Please',
      audioUrl: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
    ),
  ];

  /// Returns a copy of all flashcards.
  List<Flashcard> getAllFlashcards() => List.of(_flashcards);

  /// Returns flashcards that are due for review today or in the past.
  List<Flashcard> getDueFlashcards() {
    final now = DateTime.now();
    // Filter cards where the next review date is before or at the current moment.
    return _flashcards.where((card) => card.nextReview.isBefore(now) || card.nextReview.isAtSameMomentAs(now)).toList();
  }

  /// Updates an existing flashcard in the list.
  void updateFlashcard(Flashcard updatedCard) {
    final index = _flashcards.indexWhere((card) => card.id == updatedCard.id);
    if (index != -1) {
      _flashcards[index] = updatedCard;
    }
  }

  /// Adds a new flashcard to the list.
  void addFlashcard(Flashcard newCard) {
    _flashcards.add(newCard);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LangLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal, // A pleasant base color for Material 3
        useMaterial3: true,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlashcardService _flashcardService = FlashcardService();
  Flashcard? _currentCard;
  bool _showTranslation = false;
  bool _isPlayingAudio = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadNextCard();
    // Listen for audio completion to update playing state.
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlayingAudio = false;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Loads the next flashcard due for review.
  /// If multiple cards are due, it picks one randomly for variety.
  void _loadNextCard() {
    final dueCards = _flashcardService.getDueFlashcards();
    setState(() {
      if (dueCards.isNotEmpty) {
        // Randomly select one of the due cards.
        _currentCard = dueCards[Random().nextInt(dueCards.length)];
        _showTranslation = false; // Hide translation for the new card
      } else {
        _currentCard = null; // No cards left to review today
      }
    });
  }

  /// Plays the audio for the current flashcard.
  Future<void> _playAudio() async {
    if (_currentCard?.audioUrl == null || _isPlayingAudio) {
      if (_currentCard?.audioUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No audio available for this word.')),
        );
      }
      return;
    }
    setState(() {
      _isPlayingAudio = true;
    });
    try {
      // Play audio from the provided URL.
      await _audioPlayer.play(UrlSource(_currentCard!.audioUrl!));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
      setState(() {
        _isPlayingAudio = false;
      });
    }
  }

  /// Handles the review outcome for the current flashcard.
  void _reviewCard(ReviewOutcome outcome) {
    if (_currentCard == null) return;

    // Update the card's spaced repetition parameters based on the outcome.
    _currentCard!.review(outcome);
    // Persist the updated card state (in this case, update in the service list).
    _flashcardService.updateFlashcard(_currentCard!);

    // Load the next card for review.
    _loadNextCard();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LangLearn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'All Words',
            onPressed: () {
              // Navigate to the screen listing all words.
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AllWordsScreen(
                    flashcardService: _flashcardService,
                    // Callback to refresh the main screen's card if the list changes.
                    onCardUpdated: _loadNextCard,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _currentCard == null
          ? Center(
              // Empty state when no cards are due for review.
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: colorScheme.primary),
                    const SizedBox(height: 24),
                    Text(
                      'All cards reviewed for today!',
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Come back tomorrow for more, or add new words.',
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to the All Words screen to add new words.
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AllWordsScreen(
                              flashcardService: _flashcardService,
                              onCardUpdated: _loadNextCard,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Manage Words'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentCard!.word,
                            style: textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Animated visibility for the translation.
                          AnimatedOpacity(
                            opacity: _showTranslation ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _currentCard!.translation,
                              style: textTheme.headlineMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton.filledTonal(
                                iconSize: 36,
                                onPressed: _playAudio,
                                // Show loading indicator when audio is playing.
                                icon: _isPlayingAudio
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorScheme.onSurface,
                                        ),
                                      )
                                    : const Icon(Icons.volume_up),
                                tooltip: 'Play Audio',
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showTranslation = !_showTranslation;
                                  });
                                },
                                child: Text(_showTranslation ? 'Hide Translation' : 'Show Translation'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_showTranslation) // Show review buttons only after translation is revealed.
                    Column(
                      children: [
                        Text(
                          'How well did you remember?',
                          style: textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16.0,
                          runSpacing: 16.0,
                          alignment: WrapAlignment.center,
                          children: [
                            ActionChip(
                              label: const Text('Hard'),
                              avatar: const Icon(Icons.sentiment_dissatisfied),
                              onPressed: () => _reviewCard(ReviewOutcome.hard),
                            ),
                            ActionChip(
                              label: const Text('Good'),
                              avatar: const Icon(Icons.sentiment_neutral),
                              onPressed: () => _reviewCard(ReviewOutcome.good),
                            ),
                            ActionChip(
                              label: const Text('Easy'),
                              avatar: const Icon(Icons.sentiment_satisfied),
                              onPressed: () => _reviewCard(ReviewOutcome.easy),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  Text(
                    'Next review: ${DateFormat.yMMMd().format(_currentCard!.nextReview)}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Repetitions: ${_currentCard!.repetitions}, Interval: ${_currentCard!.interval.toStringAsFixed(1)} days, Ease: ${_currentCard!.easeFactor.toStringAsFixed(2)}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}

/// Screen to display all flashcards and allow adding new ones.
class AllWordsScreen extends StatefulWidget {
  final FlashcardService flashcardService;
  final VoidCallback onCardUpdated; // Callback to notify HomePage to refresh its current card.

  const AllWordsScreen({
    super.key,
    required this.flashcardService,
    required this.onCardUpdated,
  });

  @override
  State<AllWordsScreen> createState() => _AllWordsScreenState();
}

class _AllWordsScreenState extends State<AllWordsScreen> {
  late List<Flashcard> _allFlashcards;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  void _loadFlashcards() {
    setState(() {
      _allFlashcards = widget.flashcardService.getAllFlashcards();
    });
  }

  /// Shows a dialog to add a new flashcard.
  Future<void> _showAddCardDialog() async {
    final TextEditingController wordController = TextEditingController();
    final TextEditingController translationController = TextEditingController();
    final TextEditingController audioUrlController = TextEditingController(
      text: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3', // Default placeholder audio
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Flashcard'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: wordController,
                  decoration: const InputDecoration(labelText: 'Word/Phrase'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: translationController,
                  decoration: const InputDecoration(labelText: 'Translation'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: audioUrlController,
                  decoration: const InputDecoration(labelText: 'Audio URL (optional)'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              onPressed: () {
                if (wordController.text.isNotEmpty && translationController.text.isNotEmpty) {
                  final newCard = Flashcard(
                    id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID for new cards
                    word: wordController.text.trim(),
                    translation: translationController.text.trim(),
                    audioUrl: audioUrlController.text.trim().isNotEmpty ? audioUrlController.text.trim() : null,
                  );
                  widget.flashcardService.addFlashcard(newCard);
                  _loadFlashcards(); // Refresh the list of cards on this screen.
                  widget.onCardUpdated(); // Notify the home page that cards might have changed.
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Word and Translation cannot be empty.')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Words'),
      ),
      body: _allFlashcards.isEmpty
          ? Center(
              // Empty state when there are no words in the list.
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No words added yet!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first word.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _allFlashcards.length,
              itemBuilder: (context, index) {
                final card = _allFlashcards[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.word,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.translation,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Next Review: ${DateFormat.yMMMd().format(card.nextReview)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Repetitions: ${card.repetitions}, Interval: ${card.interval.toStringAsFixed(1)} days, Ease: ${card.easeFactor.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
