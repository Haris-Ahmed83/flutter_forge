import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for FilteringTextInputFormatter

void main() {
  runApp(const UnitConverterApp());
}

/// The root widget of the application, configuring Material Design settings.
class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unit Converter',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue, // Defines a primary color for Material 3
        useMaterial3: true, // Enables Material 3 design system
      ),
      home: const UnitConverterScreen(),
    );
  }
}

/// The main screen for the unit converter, managing its state.
class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  // Static constant map holding all unit conversion data.
  // The structure is: Category -> Unit Name -> Conversion Factor to Base Unit.
  // For example, for 'Length', 'kilometer' has a factor of 1000.0 because 1 km = 1000 meters (base unit).
  static const Map<String, Map<String, double>> _unitData = {
    'Length': {
      'meter': 1.0,
      'kilometer': 1000.0,
      'centimeter': 0.01,
      'millimeter': 0.001,
      'mile': 1609.34,
      'yard': 0.9144,
      'foot': 0.3048,
      'inch': 0.0254,
    },
    'Weight': {
      'kilogram': 1.0,
      'gram': 0.001,
      'milligram': 0.000001,
      'pound': 0.453592,
      'ounce': 0.0283495,
      'tonne': 1000.0,
    },
    'Volume': {
      'liter': 1.0,
      'milliliter': 0.001,
      'gallon': 3.78541,
      'quart': 0.946353,
      'pint': 0.473176,
      'cup': 0.236588,
      'fluid ounce': 0.0295735,
      'cubic meter': 1000.0,
    },
    // Temperature conversion is non-linear and more complex (e.g., Celsius to Fahrenheit requires addition/subtraction),
    // so it's omitted for this beginner-focused linear conversion example.
  };

  // State variables for the selected category and units.
  String _selectedCategory = _unitData.keys.first;
  String? _selectedFromUnit;
  String? _selectedToUnit;

  // Controller for the input text field.
  final TextEditingController _inputController = TextEditingController();

  // The calculated output value displayed to the user.
  String _outputValue =
