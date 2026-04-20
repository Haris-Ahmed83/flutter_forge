import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The main entry point of the Flutter application.
void main() {
  runApp(const MyApp());
}

/// A [ChangeNotifier] that manages the current theme mode of the application.
///
/// It holds the [_themeMode] and provides a method [toggleTheme] to switch
/// between [ThemeMode.light] and [ThemeMode.dark].
class ThemeNotifier extends ChangeNotifier {
  // Default theme mode is light.
  ThemeMode _themeMode = ThemeMode.light;

  /// Gets the current theme mode.
  ThemeMode get themeMode => _themeMode;

  /// Toggles the theme mode between light and dark.
  /// Notifies all listeners about the change.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Important: call notifyListeners() to rebuild consumers.
  }
}

/// The root widget of the application.
///
/// It sets up the [ChangeNotifierProvider] for [ThemeNotifier] and
/// configures the [MaterialApp] with light and dark themes,
/// controlled by the [ThemeNotifier].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      // Create an instance of ThemeNotifier. This will be available to all descendants.
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        // Consumer rebuilds its children when ThemeNotifier changes.
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Dark Light Mode Toggle',
            debugShowCheckedModeBanner: false,
            // Enable Material 3 design.
            useMaterial3: true,
            // Define the light theme.
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueAccent,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blueAccent;
                  }
                  return Colors.grey[400];
                }),
                trackColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blueAccent.withOpacity(0.5);
                  }
                  return Colors.grey[300];
                }),
              ),
            ),
            // Define the dark theme.
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueAccent,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey[800], // Darker card background
              ),
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blueAccent;
                  }
                  return Colors.grey[600];
                }),
                trackColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blueAccent.withOpacity(0.5);
                  }
                  return Colors.grey[700];
                }),
              ),
            ),
            // Set the current theme mode based on the ThemeNotifier's state.
            themeMode: themeNotifier.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

/// The home page of the application, demonstrating the theme toggle.
///
/// It displays some text and a [SwitchListTile] to change the theme mode.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeNotifier without listening for changes (listen: false)
    // because we only need to call a method (toggleTheme).
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    // Access the ThemeNotifier and listen for changes to update the UI (e.g., icon).
    // This is typically done with a Consumer or by setting listen: true
    // on Provider.of in a build method.
    final currentThemeMode = Provider.of<ThemeNotifier>(context).themeMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Toggle App'),
        actions: [
          // Display a different icon based on the current theme mode.
          Icon(
            currentThemeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          const SizedBox(width: 16), // Spacing for the icon
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display a welcome message using the app's headline medium text style.
              Text(
                'Welcome to the Theme Toggle App!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Display the current theme status.
              Text(
                'Current Theme:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                currentThemeMode.toString().split('.').last.toUpperCase(), // e.g., "DARK" or "LIGHT"
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 50),
              // A Card widget to visually group the theme toggle switch.
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: SwitchListTile(
                    title: const Text(
                      'Enable Dark Mode',
                      style: TextStyle(fontSize: 18),
                    ),
                    // The switch value is true if the current theme mode is dark.
                    value: currentThemeMode == ThemeMode.dark,
                    onChanged: (bool value) {
                      // Call toggleTheme method on the ThemeNotifier.
                      themeNotifier.toggleTheme();
                    },
                    secondary: Icon(
                      currentThemeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                      size: 30,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Example of a button that respects the current theme.
              ElevatedButton.icon(
                onPressed: () {
                  // Show a simple SnackBar to demonstrate UI interaction.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Theme is ${currentThemeMode.toString().split('.').last}!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Show Info'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
