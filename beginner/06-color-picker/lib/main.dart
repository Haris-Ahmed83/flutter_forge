// main.dart

import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ColorPickerApp());
}

class ColorPickerApp extends StatelessWidget {
  const ColorPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Picker',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple, // A nice seed for Material 3
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system, // Follow system theme by default
      home: const ColorPickerScreen(),
    );
  }
}

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  Color _selectedColor = Colors.blue; // Initial color
  String _colorHexCode = '#FF0000FF'; // Initial hex code

  @override
  void initState() {
    super.initState();
    _updateColorInfo(_selectedColor); // Update hex code for initial color
  }

  // Generates a random color for the "Random Color" button
  Color _generateRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255, // Full opacity
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
  }

  // Updates the selected color and its hex code representation
  void _updateColor(Color newColor) {
    setState(() {
      _selectedColor = newColor;
      _updateColorInfo(newColor);
    });
  }

  // Converts a Color object to its ARGB hex string
  void _updateColorInfo(Color color) {
    _colorHexCode = '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Picker'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Tap the colored squares to pick a color!',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Display area for the currently selected color
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withOpacity(0.6),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _colorHexCode,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: _selectedColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),

              // Grid of predefined colors
              GridView.builder(
                shrinkWrap: true, // Important for nested scroll views
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the grid itself
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: Colors.primaries.length,
                itemBuilder: (BuildContext context, int index) {
                  final Color color = Colors.primaries[index];
                  return GestureDetector(
                    onTap: () => _updateColor(color),
                    child: Tooltip(
                      message: '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}',
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedColor == color ? colorScheme.primary : Colors.transparent,
                            width: _selectedColor == color ? 3.0 : 0.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // Button to pick a random color
              ElevatedButton.icon(
                onPressed: () => _updateColor(_generateRandomColor()),
                icon: const Icon(Icons.shuffle),
                label: const Text('Pick Random Color'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Make button full width
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
