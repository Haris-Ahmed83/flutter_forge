import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Age Calculator',
      // Enable Material 3 design
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AgeCalculatorPage(),
    );
  }
}

class AgeCalculatorPage extends StatefulWidget {
  const AgeCalculatorPage({super.key});

  @override
  State<AgeCalculatorPage> createState() => _AgeCalculatorPageState();
}

class _AgeCalculatorPageState extends State<AgeCalculatorPage> {
  DateTime? _selectedBirthDate; // Stores the user's selected birth date
  String _ageResult = ''; // Stores the calculated age string

  /// Displays a date picker and updates [_selectedBirthDate] and [_ageResult].
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(), // Default to current date if no date selected
      firstDate: DateTime(1900), // Allow selection from 1900
      lastDate: DateTime.now(), // Disallow future dates
      helpText: 'Select your birth date',
      confirmText: 'Select',
      cancelText: 'Not now',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _calculateAge(); // Recalculate age whenever a new date is selected
      });
    }
  }

  /// Calculates the age based on [_selectedBirthDate] and updates [_ageResult].
  void _calculateAge() {
    if (_selectedBirthDate == null) {
      setState(() {
        _ageResult = 'Please select your birth date.';
      });
      return;
    }

    final DateTime today = DateTime.now();
    final DateTime birthDate = _selectedBirthDate!;

    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    // Adjust years and months if birth month/day is after current month/day
    if (months < 0 || (months == 0 && days < 0)) {
      years--;
      months += 12; // Add 12 months to make it positive
    }

    // Adjust months and days if birth day is after current day
    if (days < 0) {
      months--;
      // Get the number of days in the *previous* month relative to today
      // DateTime(today.year, today.month, 0) gives the last day of the previous month.
      final int daysInPreviousMonth = DateTime(today.year, today.month, 0).day;
      days += daysInPreviousMonth;
    }

    // Handle edge case where months might become negative after day adjustment
    // (e.g., if today is Feb 10 and birth is Jan 15, and after adjusting days, months becomes -1)
    if (months < 0) {
      years--;
      months += 12;
    }

    setState(() {
      _ageResult = 'You are $years years, $months months, and $days days old.';
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize age result on first load, in case a default date is set or for initial prompt.
    // Here, we'll just show the prompt.
    _ageResult = 'Please select your birth date.';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Age Calculator'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Display selected birth date or a prompt
              Text(
                _selectedBirthDate == null
                    ? 'No birth date selected'
                    : 'Birth Date: ${
                        _selectedBirthDate!.day.toString().padLeft(2, '0')
                      }/${
                        _selectedBirthDate!.month.toString().padLeft(2, '0')
                      }/${_selectedBirthDate!.year}',
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Button to open the date picker
              ElevatedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: const Text('Select Birth Date'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 48),

              // Display the calculated age result
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Your Age:',
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _ageResult,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
