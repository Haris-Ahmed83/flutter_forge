import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and currency formatting
import 'package:uuid/uuid.dart'; // For generating unique IDs

// TODO: Add the following dependencies to your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   intl: ^0.18.1 // Or the latest version
//   uuid: ^4.2.1 // Or the latest version
//   fl_chart: ^0.65.0 // Or the latest version (for production-quality charts)

import 'package:fl_chart/fl_chart.dart'; // For charts

void main() {
  runApp(const MyApp());
}

// --- Data Models ---

/// Enum representing different categories for expenses.
enum ExpenseCategory {
  food,
  transport,
  shopping,
  utilities,
  entertainment,
  health,
  other,
}

/// Extension methods for [ExpenseCategory] to provide associated icons, colors, and names.
extension ExpenseCategoryExtension on ExpenseCategory {
  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.fastfood;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.utilities:
        return Icons.lightbulb;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.health:
        return Icons.medical_services;
      case ExpenseCategory.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.shopping:
        return Colors.purple;
      case ExpenseCategory.utilities:
        return Colors.green;
      case ExpenseCategory.entertainment:
        return Colors.red;
      case ExpenseCategory.health:
        return Colors.teal;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  String get name {
    return toString().split('.').last.capitalize();
  }
}

/// Simple string capitalization helper.
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

/// Represents a single expense entry.
class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  /// Creates a copy of the expense with optional new values.
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
}

// --- Main App Widget ---

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      themeMode: ThemeMode.system, // Uses system theme (light/dark)
      home: const ExpenseTrackerHomePage(),
    );
  }
}

// --- Home Page ---

/// The main home page of the Expense Tracker, managing state for expenses and navigation.
class ExpenseTrackerHomePage extends StatefulWidget {
  const ExpenseTrackerHomePage({super.key});

  @override
  State<ExpenseTrackerHomePage> createState() => _ExpenseTrackerHomePageState();
}

class _ExpenseTrackerHomePageState extends State<ExpenseTrackerHomePage> {
  final List<Expense> _expenses = []; // In-memory list for expenses (CRUD data source)
  int _selectedIndex = 0; // Current index for BottomNavigationBar
  late PageController _pageController; // Controller for PageView navigation

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadSampleData(); // Load some initial data for demonstration
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Loads sample data into the [_expenses] list.
  void _loadSampleData() {
    final now = DateTime.now();
    setState(() {
      _expenses.addAll([
        Expense(
          id: const Uuid().v4(),
          title: 'Groceries',
          amount: 55.20,
          date: now.subtract(const Duration(days: 2)),
          category: ExpenseCategory.food,
        ),
        Expense(
          id: const Uuid().v4(),
          title: 'Bus Ticket',
          amount: 3.50,
          date: now.subtract(const Duration(days: 1)),
          category: ExpenseCategory.transport,
        ),
        Expense(
          id: const Uuid().v4(),
          title: 'New Shirt',
          amount: 30.00,
          date: now.subtract(const Duration(days: 3)),
          category: ExpenseCategory.shopping,
        ),
        Expense(
          id: const Uuid().v4(),
          title: 'Electricity Bill',
          amount: 75.80,
          date: now.subtract(const Duration(days: 10)),
          category: ExpenseCategory.utilities,
        ),
        Expense(
          id: const Uuid().v4(),
          title: 'Movie Night',
          amount: 25.00,
          date:
