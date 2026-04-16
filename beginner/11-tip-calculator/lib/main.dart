import 'package:flutter/material.dart';
import 'dart:math' as math; // Used for max/min if needed, but not strictly for this app.
                       // Included as `math` is a key concept.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tip Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Material 3 design enabled
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const TipCalculatorScreen(),
    );
  }
}

class TipCalculatorScreen extends StatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  State<TipCalculatorScreen> createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends State<TipCalculatorScreen> {
  double _billAmount = 50.0; // Default bill amount
  double _tipPercentage = 0.15; // Default tip percentage (15%)
  int _numberOfPeople = 1; // Default number of people

  // --- Math Calculations ---
  double get _tipAmount => _billAmount * _tipPercentage;
  double get _totalAmount => _billAmount + _tipAmount;
  double get _amountPerPerson => _numberOfPeople > 0 ? _totalAmount / _numberOfPeople : _totalAmount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tip Calculator'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill Amount Input
            Text(
              'Enter Bill Amount',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 12.0),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.attach_money),
                labelText: 'Bill Amount',
                hintText: 'e.g., 50.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: (value) {
                // Update bill amount, parsing string to double.
                // If parsing fails, default to 0.0 to prevent errors.
                setState(() {
                  _billAmount = double.tryParse(value) ?? 0.0;
                });
              },
              controller: TextEditingController(text: _billAmount.toStringAsFixed(2)),
            ),

            const SizedBox(height: 32.0),

            // Tip Percentage Slider
            Text(
              'Select Tip Percentage: (${(_tipPercentage * 100).toStringAsFixed(0)}%)',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 12.0),
            Slider(
              value: _tipPercentage,
              min: 0.0,
              max: 0.30, // Max 30% tip
              divisions: 30, // Increments of 1%
              label: '${(_tipPercentage * 100).toStringAsFixed(0)}%',
              onChanged: (newValue) {
                // Update tip percentage when slider value changes.
                setState(() {
                  _tipPercentage = newValue;
                });
              },
            ),

            const SizedBox(height: 32.0),

            // Number of People Counter
            Text(
              'Number of People',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    // Decrease number of people, ensuring it doesn't go below 1.
                    setState(() {
                      _numberOfPeople = (_numberOfPeople - 1).clamp(1, 100); // Clamp to a reasonable range
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 36.0,
                  color: colorScheme.primary,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    '$_numberOfPeople',
                    style: textTheme.displaySmall,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Increase number of people.
                    setState(() {
                      _numberOfPeople = (_numberOfPeople + 1).clamp(1, 100); // Clamp to a reasonable range
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 36.0,
                  color: colorScheme.primary,
                ),
              ],
            ),

            const SizedBox(height: 40.0),

            // Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Total Bill Summary',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 30, thickness: 1.5),
                    _buildSummaryRow(
                      context,
                      'Bill Amount:',
                      '\$${_billAmount.toStringAsFixed(2)}',
                    ),
                    _buildSummaryRow(
                      context,
                      'Tip Amount (${(_tipPercentage * 100).toStringAsFixed(0)}%):',
                      '\$${_tipAmount.toStringAsFixed(2)}',
                    ),
                    _buildSummaryRow(
                      context,
                      'Total Amount:',
                      '\$${_totalAmount.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                    const Divider(height: 30, thickness: 1.5),
                    _buildSummaryRow(
                      context,
                      'Amount Per Person:',
                      '\$${_amountPerPerson.toStringAsFixed(2)}',
                      isPerPerson: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent summary rows
  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isTotal = false, bool isPerPerson = false}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal || isPerPerson
                ? textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                : textTheme.bodyLarge,
          ),
          Text(
            value,
            style: isTotal || isPerPerson
                ? textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                : textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
