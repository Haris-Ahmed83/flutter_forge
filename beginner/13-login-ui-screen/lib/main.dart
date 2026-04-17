import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        // Define a color scheme for Material 3 design.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Primary color for the app.
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          tertiary: Colors.purpleAccent,
        ),
        useMaterial3: true, // Enable Material 3 design.
        // Customize the default appearance of InputDecoration for all TextFormFields.
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded borders for input fields.
          ),
          filled: true,
          fillColor: Colors.grey.shade50, // Light background for input fields.
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        // Customize the default appearance of ElevatedButton.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50), // Full width and fixed height.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners for buttons.
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Customize the default appearance of TextButton.
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16),
            foregroundColor: Colors.deepPurple, // Ensure text buttons use primary color.
          ),
        ),
      ),
      home: const LoginScreen(), // Set LoginScreen as the home screen.
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Global key to uniquely identify the Form widget and enable its validation methods.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;
  bool _isLoading = false; // State to manage loading indicator.
  bool _isPasswordVisible = false; // State to toggle password visibility.

  // Function to simulate a login process (e.g., API call).
  Future<void> _submitForm() async {
    // Validate all TextFormFields within the Form. If all validators return null, it's valid.
    if (_formKey.currentState!.validate()) {
      // Save all TextFormFields' values by calling their onSaved callbacks.
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true; // Show loading indicator.
      });

      // Simulate a network request or authentication process delay.
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false; // Hide loading indicator.
      });

      // Basic credential check for demonstration purposes.
      if (_email == 'test@example.com' && _password == 'password123') {
        _showSnackBar('Login Successful!', Colors.green);
        // In a real application, you would navigate to the home screen or dashboard.
      } else {
        _showSnackBar('Invalid Credentials', Colors.red);
      }
    }
  }

  // Helper function to display a SnackBar with a message and color.
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back!'),
        centerTitle: true,
        // Prevents a back button from appearing if this is the initial route.
        automaticallyImplyLeading: false,
      ),
      body: Center(
        // SingleChildScrollView allows the content to scroll if the keyboard appears
        // or if the screen size is too small.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // App Logo or Icon.
              Icon(
                Icons.lock_person,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Login to your account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),

              // The Form widget groups multiple form fields and provides validation capabilities.
              Form(
                key: _formKey, // Associate the GlobalKey with this Form.
                child: Column(
                  children: <Widget>[
                    // TextFormField for email input.
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      // Validator function to check if the email is valid.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null; // Return null if the input is valid.
                      },
                      // onSaved callback is called when Form.save() is invoked.
                      onSaved: (value) {
                        _email = value; // Store the entered email.
                      },
                      autofillHints: const [AutofillHints.email], // Helps with autofill.
                    ),
                    const SizedBox(height: 20),

                    // TextFormField for password input.
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock),
                        // Suffix icon to toggle password visibility.
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility.
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible, // Hides/shows password characters.
                      keyboardType: TextInputType.visiblePassword,
                      // Validator function to check password strength/length.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null; // Return null if the input is valid.
                      },
                      // onSaved callback is called when Form.save() is invoked.
                      onSaved: (value) {
                        _password = value; // Store the entered password.
                      },
                      autofillHints: const [AutofillHints.password], // Helps with autofill.
                    ),
                    const SizedBox(height: 24),

                    // Login Button.
                    _isLoading
                        ? const CircularProgressIndicator() // Show loading indicator while submitting.
                        : ElevatedButton(
                            onPressed: _submitForm, // Trigger form submission on press.
                            child: const Text('Login'),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Forgot Password Button.
              TextButton(
                onPressed: () {
                  _showSnackBar('Forgot Password functionality coming soon!', Colors.blue);
                },
                child: const Text('Forgot Password?'),
              ),
              const SizedBox(height: 16),
              // Sign Up Link.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      _showSnackBar('Sign Up functionality coming soon!', Colors.blue);
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
