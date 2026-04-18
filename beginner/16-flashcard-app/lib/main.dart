import 'dart:math'; // For pi and other math functions

import 'package:flutter/material.dart';

void main() {
  runApp(const FlashcardApp());
}

// 1. Flashcard Data Model
// A simple immutable class to hold the question and answer for a flashcard.
class Flashcard {
  final String question;
  final String answer;

  const Flashcard({required this.question, required this.answer});
}

// 2. Main Application Widget
// The root of the application, setting up Material Design and the main screen.
class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Enable Material 3 design
      ),
      home: const FlashcardScreen(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
