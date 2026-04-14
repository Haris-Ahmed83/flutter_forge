import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Data model for a single quiz question.
class Question {
  final String questionText;
  final List<Answer> answers;

  const Question({
    required this.questionText,
    required this.answers,
  });
}

// Data model for an answer to a question.
class Answer {
  final String text;
  final bool isCorrect;

  const Answer({
    required this.text,
    this.isCorrect = false, // Default to false if not specified.
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Enable Material 3 design.
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50), // Full width buttons
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.deepPurple.shade100,
            foregroundColor: Colors.deepPurple.shade900,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ),
      home: const QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Sample quiz data.
  final List<Question> _questions = const [
    Question(
      questionText: 'What is the capital of France?',
      answers: [
        Answer(text: 'Berlin'),
        Answer(text: 'Madrid'),
        Answer(text: 'Paris', isCorrect: true),
        Answer(text: 'Rome'),
      ],
    ),
    Question(
      questionText: 'Which planet is known as the Red Planet?',
      answers: [
        Answer(text: 'Earth'),
        Answer(text: 'Mars', isCorrect: true),
        Answer(text: 'Jupiter'),
        Answer(text: 'Venus'),
      ],
    ),
    Question(
      questionText: 'What is the largest ocean on Earth?',
      answers: [
        Answer(text: 'Atlantic Ocean'),
        Answer(text: 'Indian Ocean'),
        Answer(text: 'Arctic Ocean'),
        Answer(text: 'Pacific Ocean', isCorrect: true),
      ],
    ),
    Question(
      questionText: 'Who painted the Mona Lisa?',
      answers: [
        Answer(text: 'Vincent van Gogh'),
        Answer(text: 'Pablo Picasso'),
        Answer(text: 'Leonardo da Vinci', isCorrect: true),
        Answer(text: 'Claude Monet'),
      ],
    ),
    Question(
      questionText: 'What is the chemical symbol for water?',
      answers: [
        Answer(text: 'O2'),
        Answer(text: 'H2O', isCorrect: true),
        Answer(text: 'CO2'),
        Answer(text: 'NaCl'),
      ],
    ),
  ];

  int _currentQuestionIndex = 0; // Tracks the current question being displayed.
  int _score = 0; // Tracks the user's score.
  bool _quizFinished = false; // Controls conditional UI for showing results.

  // Handles when a user selects an answer.
  void _answerQuestion(bool isCorrect) {
    if (isCorrect) {
      _score++; // Increment score if the answer is correct.
    }

    setState(() {
      // Move to the next question.
      _currentQuestionIndex++;
      // If all questions are answered, mark quiz as finished.
      if (_currentQuestionIndex >= _questions.length) {
        _quizFinished = true;
      }
    });
  }

  // Resets the quiz to its initial state.
  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          // Conditional UI: Show ResultScreen if quiz is finished, otherwise show quiz questions.
          child: _quizFinished
              ? ResultScreen(
                  score: _score,
                  totalQuestions: _questions.length,
                  onRestartQuiz: _resetQuiz,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Display the current question.
                    QuestionWidget(
                      questionText: _questions[_currentQuestionIndex].questionText,
                    ),
                    const SizedBox(height: 32),
                    // Display answer buttons for the current question.
                    // Using `...` to spread the list of widgets directly into children.
                    ..._questions[_currentQuestionIndex].answers.map((answer) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AnswerButton(
                          answerText: answer.text,
                          onPressed: () => _answerQuestion(answer.isCorrect),
                        ),
                      );
                    }).toList(),
                    const Spacer(), // Pushes content to the top/center, leaving space at bottom
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Widget to display the question text.
class QuestionWidget extends StatelessWidget {
  final String questionText;

  const QuestionWidget({
    super.key,
    required this.questionText,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      questionText,
      style: Theme.of(context).textTheme.titleLarge,
      textAlign: TextAlign.center,
    );
  }
}

// Widget for a single answer button.
class AnswerButton extends StatelessWidget {
  final String answerText;
  final VoidCallback onPressed;

  const AnswerButton({
    super.key,
    required this.answerText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(answerText),
    );
  }
}

// Widget to display the quiz results.
class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRestartQuiz;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onRestartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (score / totalQuestions) * 100;
    String feedbackMessage;
    Color feedbackColor;

    // Conditional UI logic for feedback message based on score percentage.
    if (percentage >= 80) {
      feedbackMessage = 'Excellent! You\'re a quiz master!';
      feedbackColor = Colors.green.shade700;
    } else if (percentage >= 50) {
      feedbackMessage = 'Good job! You did well.';
      feedbackColor = Colors.orange.shade700;
    } else {
      feedbackMessage = 'Keep practicing! You\'ll get there.';
      feedbackColor = Colors.red.shade700;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quiz Completed!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.deepPurple),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Your Score: $score / $totalQuestions',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          feedbackMessage,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: feedbackColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: onRestartQuiz,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Restart Quiz'),
        ),
      ],
    );
  }
}
