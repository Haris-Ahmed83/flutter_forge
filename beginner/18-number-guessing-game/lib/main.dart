import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Guessing Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NumberGuessingGame(),
    );
  }
}

class NumberGuessingGame extends StatefulWidget {
  const NumberGuessingGame({super.key});

  @override
  State<NumberGuessingGame> createState() => _NumberGuessingGameState();
}

class _NumberGuessingGameState extends State<NumberGuessingGame> {
  final Random _randomNumberGenerator = Random();
  late int _targetNumber; // The number the user needs to guess
  late TextEditingController _guessController; // Controller for the input field
  String _feedbackMessage = ''; // Message displayed to the user (e.g., "Too high!")
  int _attempts = 0; // Counter for the number of guesses
  bool _gameWon = false; // Flag to indicate if the game has been won

  @override
  void initState() {
    super.initState();
    _guessController = TextEditingController();
    _resetGame(); // Initialize the game state
  }

  @override
  void dispose() {
    _guessController.dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  /// Resets the game to its initial state, generating a new target number.
  void _resetGame() {
    setState(() {
      _targetNumber = _randomNumberGenerator.nextInt(100) + 1; // Generate a number between 1 and 100
      _feedbackMessage = 'I\'m thinking of a number between 1 and 100.';
      _attempts = 0;
      _gameWon = false;
      _guessController.clear(); // Clear any previous input
    });
  }

  /// Handles the user's guess submission.
  void _submitGuess() {
    // Attempt to parse the user's input as an integer.
    final String inputText = _guessController.text;
    final int? userGuess = int.tryParse(inputText);

    // Validate the input.
    if (userGuess == null) {
      setState(() {
        _feedbackMessage = 'Please enter a valid number.';
      });
      return;
    }

    if (userGuess < 1 || userGuess > 100) {
      setState(() {
        _feedbackMessage = 'Please enter a number between 1 and 100.';
      });
      return;
    }

    // Increment the attempt counter and provide feedback based on the guess.
    setState(() {
      _attempts++;
      if (userGuess < _targetNumber) {
        _feedbackMessage = 'Your guess is too low! Try again.';
      } else if (userGuess > _targetNumber) {
        _feedbackMessage = 'Your guess is too high! Try again.';
      } else {
        _feedbackMessage = 'Congratulations! You guessed the number $_targetNumber!';
        _gameWon = true; // Set game won flag
      }
    });

    // Clear the input field after each guess, unless the game is won.
    if (!_gameWon) {
      _guessController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Guessing Game'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                _feedbackMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _gameWon ? Colors.green.shade700 : null,
                    ),
              ),
              const SizedBox(height: 24),
              if (!_gameWon) // Only show input field and guess button if game is not won
                TextField(
                  controller: _guessController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly // Allow only digits
                  ],
                  decoration: InputDecoration(
                    labelText: 'Enter your guess (1-100)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _guessController.clear(),
                    ),
                  ),
                  onSubmitted: (_) => _submitGuess(), // Allow submitting with keyboard enter
                ),
              if (!_gameWon) const SizedBox(height: 16),
              if (!_gameWon)
                ElevatedButton(
                  onPressed: _submitGuess,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Guess'),
                ),
              const SizedBox(height: 24),
              Text(
                'Attempts: $_attempts',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _resetGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _gameWon ? Colors.green : Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(_gameWon ? 'Play Again' : 'Reset Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
