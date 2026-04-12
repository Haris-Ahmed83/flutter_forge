import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for FilteringTextInputFormatter

void main() {
  runApp(const BMICalculatorApp());
}

/// The root widget of the BMI Calculator application.
class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      // Enable Material 3 design
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48), // Full width button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const BMICalculatorHomePage(),
    );
  }
}

/// The home page of the BMI Calculator, a stateful widget to manage user input and results.
class BMICalculatorHomePage extends StatefulWidget {
  const BMICalculatorHomePage({super.key});

  @override
  State<BMICalculatorHomePage> createState() => _BMICalculatorHomePageState();
}

/// The state for the BMICalculatorHomePage.
class _BMICalculatorHomePageState extends State<BMICalculatorHomePage> {
  // Controllers for text input fields
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // Global key for form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variables to store calculation results and messages
  double? _bmiResult;
  String _bmiCategory = '';
  String _message = '';

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  /// Calculates the BMI based on user input for weight and height.
  void _calculateBMI() {
    // Clear previous messages and results
    setState(() {
      _bmiResult = null;
      _bmiCategory = '';
      _message = '';
    });

    // Validate all fields in the form
    if (_formKey.currentState!.validate()) {
      try {
        final double weight = double.parse(_weightController.text);
        final double heightCm = double.parse(_heightController.text);

        // Convert height from centimeters to meters for BMI calculation
        final double heightMeters = heightCm / 100;

        // BMI calculation logic: weight (kg) / (height (m) * height (m))
        final double bmi = weight / (heightMeters * heightMeters);

        // Determine BMI category based on standard ranges
        String category;
        if (bmi < 18.5) {
          category = 'Underweight';
        } else if (bmi >= 18.5 && bmi <= 24.9) {
          category = 'Normal weight';
        } else if (bmi >= 25.0 && bmi <= 29.9) {
          category = 'Overweight';
        } else {
          category = 'Obesity';
        }

        // Update state with calculated BMI and category
        setState(() {
          _bmiResult = bmi;
          _bmiCategory = category;
          _message = 'Your BMI is ${_bmiResult!.toStringAsFixed(2)}. You are in the "$_bmiCategory" category.';
        });
      } on FormatException {
        // Handle cases where parsing to double fails (should be caught by validator but good for robustness)
        setState(() {
          _message = 'Please enter valid numeric values for weight and height.';
        });
      } catch (e) {
        // Catch any other unexpected errors during calculation
        setState(() {
          _message = 'An error occurred: ${e.toString()}';
        });
      }
    } else {
      // If form validation fails, inform the user
      setState(() {
        _message = 'Please fill in all fields correctly.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
      ),
      body: SingleChildScrollView(
        // Use SingleChildScrollView to prevent overflow when keyboard appears
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the GlobalKey to the Form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Input Card for Weight
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        // Allow only numbers and a single decimal point
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          hintText: 'e.g., 70.5',
                          suffixText: 'kg',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid weight';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Input Card for Height
              Card(
                margin: const EdgeInsets.only(bottom: 24.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Height',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        // Allow only numbers and a single decimal point
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          hintText: 'e.g., 175.0',
                          suffixText: 'cm',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid height';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Calculate Button
              ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Calculate BMI'),
              ),

              // Display Results or Messages
              if (_message.isNotEmpty) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Result',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _message,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: _bmiResult == null ? Theme.of(context).colorScheme.error : null,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (_bmiResult != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'BMI: ${_bmiResult!.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Category: $_bmiCategory',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
