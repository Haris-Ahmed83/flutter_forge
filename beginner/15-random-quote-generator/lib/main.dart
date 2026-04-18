import 'package:flutter/material.dart';
import 'dart:math';

/// Main function to run the Flutter application.
void main() {
  runApp(const QuoteApp());
}

/// A simple class to hold quote data.
class Quote {
  final String text;
  final String author;

  const Quote({required this.text, required this.author});
}

/// The root widget of the application.
class QuoteApp extends StatelessWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Quote Generator',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true, // Enable Material 3 design
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // Button background color
            foregroundColor: Colors.white, // Button text color
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const QuoteGeneratorPage(),
    );
  }
}

/// A stateful widget to display and generate random quotes.
class QuoteGeneratorPage extends StatefulWidget {
  const QuoteGeneratorPage({super.key});

  @override
  State<QuoteGeneratorPage> createState() => _QuoteGeneratorPageState();
}

class _QuoteGeneratorPageState extends State<QuoteGeneratorPage> {
  // List of sample quotes. Demonstrates the 'List' concept.
  final List<Quote> _quotes = const [
    Quote(
        text: 'The only way to do great work is to love what you do.',
        author: 'Steve Jobs'),
    Quote(
        text: 'Innovation distinguishes between a leader and a follower.',
        author: 'Steve Jobs'),
    Quote(
        text: 'The future belongs to those who believe in the beauty of their dreams.',
        author: 'Eleanor Roosevelt'),
    Quote(
        text: 'Strive not to be a success, but rather to be of value.',
        author: 'Albert Einstein'),
    Quote(
        text: 'The mind is everything. What you think you become.',
        author: 'Buddha'),
    Quote(
        text: 'The only impossible journey is the one you never begin.',
        author: 'Tony Robbins'),
    Quote(
        text: 'Believe you can and you\'re halfway there.',
        author: 'Theodore Roosevelt'),
    Quote(
        text: 'The best way to predict the future is to create it.',
        author: 'Abraham Lincoln'),
  ];

  late Random _random; // Random number generator. Demonstrates the 'Random' concept.
  Quote? _currentQuote; // Stores the currently displayed quote.

  @override
  void initState() {
    super.initState();
    _random = Random(); // Initialize the random number generator.
    _generateRandomQuote(); // Display a quote when the app starts.
  }

  /// Generates a random quote from the list and updates the UI.
  void _generateRandomQuote() {
    setState(() {
      // Pick a random index from the _quotes list.
      final int randomIndex = _random.nextInt(_quotes.length);
      _currentQuote = _quotes[randomIndex]; // Set the current quote.
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Quote Generator'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the quote in a Card for a clean, elevated look.
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Quote text
                      Text(
                        _currentQuote?.text ?? 'Press the button to get a quote!',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Quote author
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '- ${_currentQuote?.author ?? 'Unknown'}',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Button to generate a new random quote.
              ElevatedButton(
                onPressed: _generateRandomQuote,
                child: const Text('New Quote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
