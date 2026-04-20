import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback

void main() {
  // Ensure Flutter widgets are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations to portrait only for a calculator app.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const CalculatorApp());
  });
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Enable Material 3 design.
        useMaterial3: true,
        // Define a dark color scheme for a modern calculator look.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          // Customizing colors for better contrast and calculator feel.
          primary: Colors.deepPurpleAccent,
          onPrimary: Colors.white,
          primaryContainer: Colors.deepPurple[800],
          onPrimaryContainer: Colors.white,
          secondary: Colors.blueGrey,
          onSecondary: Colors.white,
          surface: const Color(0xFF1C1C1C), // Dark background for the app
          onSurface: Colors.white,
          background: const Color(0xFF000000), // Even darker background for display
          onBackground: Colors.white,
        ),
        // Define text theme for consistent typography.
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
          headlineLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
          labelLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        // Customize button styles.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0"; // Current number displayed
  String _history = ""; // History of operations
  double _num1 = 0.0; // First operand
  double _num2 = 0.0; // Second operand
  String _operand = ""; // Current arithmetic operation (+, -, *, /)
  bool _shouldClearDisplay = false; // Flag to clear display for new input

  // Callback function for button presses.
  void _onButtonPressed(String buttonText) {
    HapticFeedback.lightImpact(); // Provide haptic feedback on button press

    setState(() {
      if (buttonText == "C") {
        // Clear all state
        _output = "0";
        _history = "";
        _num1 = 0.0;
        _num2 = 0.0;
        _operand = "";
        _shouldClearDisplay = false;
      } else if (buttonText == "DEL") {
        // Delete last character
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = "0";
        }
      } else if (buttonText == "+/-") {
        // Toggle sign
        if (_output != "0") {
          if (_output.startsWith("-")) {
            _output = _output.substring(1);
          } else {
            _output = "-$_output";
          }
        }
      } else if (buttonText == "." ||
          buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷" ||
          buttonText == "=") {
        // Handle operations and decimal point
        if (buttonText == ".") {
          if (_shouldClearDisplay) {
            _output = "0."; // Start new number with "0."
            _shouldClearDisplay = false;
          } else if (!_output.contains(".")) {
            _output += "."; // Add decimal if not already present
          }
        } else if (buttonText == "=") {
          if (_operand.isNotEmpty && _history.isNotEmpty) {
            _num2 = double.parse(_output);
            // Construct the full expression for history.
            _history += " $_num2 =";
            _output = _calculate(_num1, _num2, _operand).toString();
            // Reset for next calculation, but keep result in _num1 for chain operations.
            _num1 = double.tryParse(_output) ?? 0.0;
            _operand = "";
            _shouldClearDisplay = true;
          }
        } else {
          // Handle +, -, ×, ÷
          if (_operand.isNotEmpty && _num1 != 0.0 && !_shouldClearDisplay) {
            // If there's an existing operation and _num1, calculate intermediate result
            _num2 = double.parse(_output);
            _num1 = _calculate(_num1, _num2, _operand);
            _history = "${_formatNumber(_num1)} $buttonText";
            _output = _formatNumber(_num1); // Display intermediate result
          } else {
            // Store the first number and operand
            _num1 = double.parse(_output);
            _history = "${_formatNumber(_num1)} $buttonText";
          }
          _operand = buttonText;
          _shouldClearDisplay = true; // Clear display for next number input
        }
      } else {
        // Handle digit presses
        if (_shouldClearDisplay || _output == "0") {
          _output = buttonText;
          _shouldClearDisplay = false;
        } else {
          _output += buttonText;
        }
      }
    });
  }

  // Performs the arithmetic calculation.
  double _calculate(double num1, double num2, String operand) {
    switch (operand) {
      case "+":
        return num1 + num2;
      case "-":
        return num1 - num2;
      case "×":
        return num1 * num2;
      case "÷":
        if (num2 == 0) return double.nan; // Handle division by zero
        return num1 / num2;
      default:
        return num2;
    }
  }

  // Formats numbers to remove trailing .0 if they are integers.
  String _formatNumber(double number) {
    if (number.isNaN) {
      return "Error";
    }
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Calculator Display Area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // History Display
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _history,
                        style: textTheme.headlineLarge?.copyWith(color: colorScheme.onBackground.withOpacity(0.7)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Current Output Display
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _formatNumber(double.tryParse(_output) ?? 0.0),
                        style: textTheme.displayLarge?.copyWith(
                          color: colorScheme.onBackground,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Calculator Buttons Grid
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Row 1: C, DEL, +/-, ÷
                    _buildButtonRow(
                      context,
                      ["C", "DEL", "+/-", "÷"],
                      [
                        colorScheme.secondaryContainer, // C
                        colorScheme.secondaryContainer, // DEL
                        colorScheme.secondaryContainer, // +/-
                        colorScheme.primary, // ÷
                      ],
                      [
                        colorScheme.onSecondaryContainer,
                        colorScheme.onSecondaryContainer,
                        colorScheme.onSecondaryContainer,
                        colorScheme.onPrimary,
                      ],
                    ),
                    // Row 2: 7, 8, 9, ×
                    _buildButtonRow(
                      context,
                      ["7", "8", "9", "×"],
                      [
                        colorScheme.surface, colorScheme.surface, colorScheme.surface, // Numbers
                        colorScheme.primary, // ×
                      ],
                      [
                        colorScheme.onSurface, colorScheme.onSurface, colorScheme.onSurface,
                        colorScheme.onPrimary,
                      ],
                    ),
                    // Row 3: 4, 5, 6, -
                    _buildButtonRow(
                      context,
                      ["4", "5", "6", "-"],
                      [
                        colorScheme.surface, colorScheme.surface, colorScheme.surface,
                        colorScheme.primary, // -
                      ],
                      [
                        colorScheme.onSurface, colorScheme.onSurface, colorScheme.onSurface,
                        colorScheme.onPrimary,
                      ],
                    ),
                    // Row 4: 1, 2, 3, +
                    _buildButtonRow(
                      context,
                      ["1", "2", "3", "+"],
                      [
                        colorScheme.surface, colorScheme.surface, colorScheme.surface,
                        colorScheme.primary, // +
                      ],
                      [
                        colorScheme.onSurface, colorScheme.onSurface, colorScheme.onSurface,
                        colorScheme.onPrimary,
                      ],
                    ),
                    // Row 5: 0, ., =
                    _buildButtonRow(
                      context,
                      ["0", ".", "="],
                      [
                        colorScheme.surface, // 0
                        colorScheme.surface, // .
                        colorScheme.primary, // =
                      ],
                      [
                        colorScheme.onSurface,
                        colorScheme.onSurface,
                        colorScheme.onPrimary,
                      ],
                      // Special treatment for '0' to take 2 columns
                      zeroButtonSpan: 2,
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

  // Helper to build a row of calculator buttons.
  Widget _buildButtonRow(
    BuildContext context,
    List<String> buttonTexts,
    List<Color> backgroundColors,
    List<Color> foregroundColors, {
    int zeroButtonSpan = 1,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttonTexts.map((text) {
          int index = buttonTexts.indexOf(text);
          bool isZero = (text == "0" && zeroButtonSpan > 1);

          return Expanded(
            flex: isZero ? zeroButtonSpan : 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _CalculatorButton(
                text: text,
                backgroundColor: backgroundColors[index],
                foregroundColor: foregroundColors[index],
                onPressed: () => _onButtonPressed(text),
                isZeroButton: isZero,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Custom widget for a single calculator button.
class _CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isZeroButton; // Special styling for the '0' button

  const _CalculatorButton({
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.isZeroButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(color: foregroundColor);

    return isZeroButton
        ? ClipRRect(
            borderRadius: BorderRadius.circular(50.0), // Rounded rectangle for '0'
            child: Material(
              color: backgroundColor,
              child: InkWell(
                onTap: onPressed,
                child: Align(
                  alignment: Alignment.centerLeft, // Align '0' text to the left
                  child: Padding(
                    padding: const EdgeInsets.only(left: 35.0), // Adjust padding for '0'
                    child: Text(
                      text,
                      style: textStyle,
                    ),
                  ),
                ),
              ),
            ),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: Text(
              text,
              style: textStyle,
            ),
          );
  }
}
