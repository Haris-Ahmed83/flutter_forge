import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

void main() {
  runApp(const MyApp());
}

// Enum to represent different temperature units
enum TemperatureUnit {
  celsius,
  fahrenheit,
  kelvin,
}

// Extension to provide user-friendly names and symbols for the units
extension TemperatureUnitExtension on TemperatureUnit {
  String get name {
    switch (this) {
      case TemperatureUnit.celsius:
        return 'Celsius';
      case TemperatureUnit.fahrenheit:
        return 'Fahrenheit';
      case TemperatureUnit.kelvin:
        return 'Kelvin';
    }
  }

  String get symbol {
    switch (this) {
      case TemperatureUnit.celsius:
        return '°C';
      case TemperatureUnit.fahrenheit:
        return '°F';
      case TemperatureUnit.kelvin:
        return 'K';
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Enable Material 3 design
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const TemperatureConverterScreen(),
    );
  }
}

class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() => _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  TemperatureUnit _inputUnit = TemperatureUnit.celsius;
  TemperatureUnit _outputUnit = TemperatureUnit.fahrenheit;
  String _resultText = 'Enter a value to convert';

  @override
  void initState() {
    super.initState();
    // Add a listener to the text controller to automatically convert when input changes.
    _inputController.addListener(_convertTemperature);
  }

  @override
  void dispose() {
    _inputController.removeListener(_convertTemperature);
    _inputController.dispose();
    super.dispose();
  }

  // Converts a temperature value from one unit to another.
  double _performConversion(double value, TemperatureUnit fromUnit, TemperatureUnit toUnit) {
    // Step 1: Convert input value to Celsius as an intermediate base for consistent conversion.
    double celsiusValue;
    switch (fromUnit) {
      case TemperatureUnit.celsius:
        celsiusValue = value;
        break;
      case TemperatureUnit.fahrenheit:
        celsiusValue = (value - 32) * 5 / 9;
        break;
      case TemperatureUnit.kelvin:
        celsiusValue = value - 273.15;
        break;
    }

    // Step 2: Convert from Celsius to the target output unit.
    switch (toUnit) {
      case TemperatureUnit.celsius:
        return celsiusValue;
      case TemperatureUnit.fahrenheit:
        return (celsiusValue * 9 / 5) + 32;
      case TemperatureUnit.kelvin:
        return celsiusValue + 273.15;
    }
  }

  // Triggers the conversion based on current input and selected units, then updates the result text.
  void _convertTemperature() {
    final String inputText = _inputController.text;
    if (inputText.isEmpty) {
      setState(() {
        _resultText = 'Enter a value to convert';
      });
      return;
    }

    // Attempt to parse the input text as a double.
    final double? inputValue = double.tryParse(inputText);

    if (inputValue == null) {
      setState(() {
        _resultText = 'Invalid input. Please enter a number.';
      });
      return;
    }

    // Perform the actual conversion using the helper method.
    final double convertedValue = _performConversion(inputValue, _inputUnit, _outputUnit);

    setState(() {
      // Format the result to two decimal places for readability and append the unit symbol.
      _resultText = '${convertedValue.toStringAsFixed(2)}${_outputUnit.symbol}';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme's color scheme for consistent Material 3 styling.
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView( // Allows the content to scroll if the keyboard covers input fields
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Input field for temperature value
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: <TextInputFormatter>[
                // Allows numbers, a single decimal point, and an optional leading sign.
                FilteringTextInputFormatter.allow(RegExp(r'^[+-]?\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Enter Temperature',
                hintText: 'e.g., 25.5',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    _convertTemperature(); // Clear result when input is cleared
                  },
                ),
              ),
              style: TextStyle(fontSize: 18, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 24),

            // Section for selecting the input unit using Material 3 SegmentedButton
            Text(
              'Convert From:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TemperatureUnit>(
              segments: <ButtonSegment<TemperatureUnit>>[
                ButtonSegment<TemperatureUnit>(
                  value: TemperatureUnit.celsius,
                  label: Text(TemperatureUnit.celsius.name),
                  icon: const Icon(Icons.thermostat),
                ),
                ButtonSegment<TemperatureUnit>(
                  value: TemperatureUnit.fahrenheit,
                  label: Text(TemperatureUnit.fahrenheit.name),
                  icon: const Icon(Icons.thermostat_outlined),
                ),
                ButtonSegment<TemperatureUnit>(
                  value: TemperatureUnit.kelvin,
                  label: Text(TemperatureUnit.kelvin.name),
                  icon: const Icon(Icons.science),
                ),
              ],
              selected: <TemperatureUnit>{_inputUnit},
              onSelectionChanged: (Set<TemperatureUnit> newSelection) {
                setState(() {
                  _inputUnit = newSelection.first;
                  _convertTemperature(); // Re-convert when input unit changes
                });
              },
              style: SegmentedButton.styleFrom(
                selectedForegroundColor: colorScheme.onPrimary,
                selectedBackgroundColor: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Section for selecting the output unit using Material 3 SegmentedButton
            Text(
              'Convert To:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TemperatureUnit>(
              segments: <ButtonSegment<TemperatureUnit>>[
                ButtonSegment<TemperatureUnit>(
                  value: TemperatureUnit.celsius,
                  label: Text(TemperatureUnit.celsius.name),
                  icon: const Icon(Icons.thermostat),
                ),
                ButtonSegment<TemperatureUnit>(
                  value: TemperatureUnit.fahrenheit,
                  label: Text(TemperatureUnit.fahrenheit.name),
                  icon: const Icon(Icons.thermostat_outlined),
                ),
                ButtonSegment<TemperatureUnit>(
                  value: TemperatureUnit.kelvin,
                  label: Text(TemperatureUnit.kelvin.name),
                  icon: const Icon(Icons.science),
                ),
              ],
              selected: <TemperatureUnit>{_outputUnit},
              onSelectionChanged: (Set<TemperatureUnit> newSelection) {
                setState(() {
                  _outputUnit = newSelection.first;
                  _convertTemperature(); // Re-convert when output unit changes
                });
              },
              style: SegmentedButton.styleFrom(
                selectedForegroundColor: colorScheme.onPrimary,
                selectedBackgroundColor: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Display area for the conversion result, styled with a Card
            Card(
              elevation: 4,
              color: colorScheme.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Result:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _resultText,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
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
}
