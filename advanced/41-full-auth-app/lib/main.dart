// pubspec.yaml dependencies:
//   flutter:
//     sdk: flutter
//   firebase_core: ^2.27.0  # Use the latest stable version
//   firebase_auth: ^4.3.0   # Use the latest stable version
//   google_sign_in: ^6.1.0  # Use the latest stable version
//   provider: ^6.0.5        # Use the latest stable version

// assets:
//   - assets/google_logo.png # TODO: Add a Google logo image to your assets folder

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

// TODO: Replace with your actual Firebase options (e.g., from firebase_options.dart)
// In a real app, you would generate firebase_options.dart using `flutterfire configure`
// and import it. For this example, we use placeholder values.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY', // TODO: Add your Firebase project's API key
      appId: 'YOUR_APP_ID', // TODO: Add your Firebase project's App ID
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID', // TODO: Add your Firebase project's Messaging Sender ID
      projectId: 'YOUR_PROJECT_ID', // TODO: Add your Firebase project's Project ID
      authDomain: 'YOUR_AUTH_DOMAIN', // TODO: Add your Firebase project's Auth Domain
      // databaseURL: 'YOUR_DATABASE_URL', // Optional: if you use Realtime Database
      // storageBucket: 'YOUR_STORAGE_BUCKET', // Optional: if you use Cloud Storage
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    // Provider to manage and expose the current Firebase user state throughout the app.
    ChangeNotifierProvider(
      create: (context) => AuthNotifier(),
      child: const MyApp(),
    ),
  );
}

/// A simple [ChangeNotifier] that listens to Firebase Auth state changes
/// and provides the current [User] object to its consumers.
class AuthNotifier with ChangeNotifier {
  User? _user;
  User? get user => _user;

  AuthNotifier() {
    // Listen for authentication state changes from Firebase.
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners(); // Notify all listeners when the user state changes.
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Full Auth App',
      // Define a modern Material 3 theme.
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple, // A vibrant seed color for Material 3.
        useMaterial3: true,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2.0, // Add a subtle shadow to the app bar.
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners for input fields.
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          filled: true,
          fillColor: Colors.deepPurple.shade50.withOpacity(0.5), // Light background for inputs.
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54), // Full width, fixed height for buttons.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Rounded corners for buttons.
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            textStyle: const TextStyle(fontSize: 16.0),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
      // Define a dark theme for aesthetic consistency.
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2.0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          filled: true,
          fillColor: Colors.grey.shade800.withOpacity(0.5),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            textStyle: const TextStyle(fontSize: 16.0),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
      themeMode: ThemeMode.system, // Automatically switch between light/dark based on system settings.
      // Use a Consumer to rebuild the home screen based on the authentication state.
      home: Consumer<AuthNotifier>(
        builder: (context, authNotifier, child) {
          // If a user is logged in, show the HomeScreen, otherwise show the AuthScreen.
          if (authNotifier.user == null) {
            return const AuthScreen();
          } else {
            return const HomeScreen();
          }
        },
      ),
    );
  }
}

/// Enum to manage the current authentication mode (Sign In or Sign Up).
enum AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey for managing form state and validation.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AuthMode _authMode = AuthMode.signIn; // Initial auth mode is Sign In.
  bool _isLoading = false; // Flag to show/hide loading indicator.
  String? _errorMessage; // Stores any error messages to display to the user.

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles email/password authentication (Sign In or Sign Up).
  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form validation fails, do not proceed.
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error messages.
    });

    try {
      if (_authMode == AuthMode.signIn) {
        // Attempt to sign in with email and password.
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Attempt to create a new user with email and password.
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase authentication errors.
      setState(() {
        _errorMessage = e.message ?? 'An unknown authentication error occurred.';
      });
    } catch (e) {
      // Catch any other unexpected errors.
      setState(() {
        _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false; // Always stop loading, regardless of success or failure.
      });
    }
  }

  /// Handles Google Sign-In authentication.
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error messages.
    });

    try {
      // Initiate the Google Sign-In flow.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled the sign-in process.
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the authentication details from the Google user.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // Create a new credential for Firebase using Google's ID token and access token.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential.
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Google Sign-In failed.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred during Google Sign-In: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false; // Always stop loading.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_authMode == AuthMode.signIn ? 'Sign In' : 'Sign Up'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.lock_person_rounded, // App logo/icon.
                size: 100,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 32.0),
              Text(
                _authMode == AuthMode.signIn ? 'Welcome Back!' : 'Create Your Account',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true, // Hide password input.
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) {
                          return 'Password must be at least 6 characters long.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    // Display error message if present.
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // Show a loading indicator or the submit button.
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submitAuthForm,
                            child: Text(_authMode == AuthMode.signIn ? 'Sign In' : 'Sign Up'),
                          ),
                    const SizedBox(height: 16.0),
                    // Button to toggle between Sign In and Sign Up modes.
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _authMode = _authMode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn;
                          _errorMessage = null; // Clear error when switching mode.
                          _formKey.currentState?.reset(); // Clear form fields on mode switch.
                          _emailController.clear();
                          _passwordController.clear();
                        });
                      },
                      child: Text(
                        _authMode == AuthMode.signIn
                            ? 'Don\'t have an account? Sign Up'
                            : 'Already have an account? Sign In',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              Text(
                'OR',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32.0),
              // Show a loading indicator or the Google Sign-In button.
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: Image.asset(
                        'assets/google_logo.png', // TODO: Ensure you have 'assets/google_logo.png' in your project and declared in pubspec.yaml.
                        height: 24.0,
                        width: 24.0,
                      ),
                      label: const Text('Continue with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surfaceVariant, // Distinct background for Google button.
                        foregroundColor: colorScheme.onSurfaceVariant,
                        minimumSize: const Size(double.infinity, 54),
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                        textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current user from the AuthNotifier via Provider.
    final User? user = Provider.of<AuthNotifier>(context).user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out the current user.
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle_rounded, // Success icon.
                size: 100,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 32.0),
              Text(
                'Welcome!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'You are logged in as:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        user?.email ?? 'Guest User', // Display user's email.
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (user?.displayName != null) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          '(${user!.displayName!})', // Display user's display name if available.
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (user?.photoURL != null) ...[
                        const SizedBox(height: 16.0),
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(user!.photoURL!), // Display user's profile picture.
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48.0),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut(); // Sign out action.
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error, // Use error color for sign-out button.
                  foregroundColor: colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
