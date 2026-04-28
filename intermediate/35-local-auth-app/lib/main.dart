import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

// TODO: IMPORTANT SETUP INSTRUCTIONS FOR local_auth PACKAGE:
// 1. Add `local_auth: ^latest_version` to your `pubspec.yaml`.
//
// 2. Android:
//    - Open `android/app/src/main/AndroidManifest.xml`.
//    - Add the following permissions inside the `<manifest>` tag, before `<application>`:
//      `<uses-permission android:name="android.permission.USE_BIOMETRIC"/>`
//      `<uses-permission android:name="android.permission.USE_FINGERPRINT"/>`
//    - Ensure `minSdkVersion` in `android/app/build.gradle` is at least 23.
//
// 3. iOS:
//    - Open `ios/Runner/Info.plist`.
//    - Add a key for `NSFaceIDUsageDescription` with a string value explaining why your app needs Face ID:
//      `<key>NSFaceIDUsageDescription</key>`
//      `<string>Why is my app asking for Face ID?</string>`
//
// 4. macOS:
//    - Open `macos/Runner/Info.plist`.
//    - Add a key for `NSFaceIDUsageDescription` (similar to iOS).
//    - Open `macos/Runner/Runner.entitlements`.
//    - Add the following keys:
//      `<key>com.apple.security.app-sandbox</key>`
//      `<true/>`
//      `<key>com.apple.security.device.biometry</key>`
//      `<true/>`

void main() {
  runApp(const LocalAuthApp());
}

class LocalAuthApp extends StatelessWidget {
  const LocalAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.deepPurple,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.deepPurpleAccent,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  String _authorizedStatus = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _getAvailableBiometrics();
  }

  // Checks if the device supports biometrics.
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      // Handle platform-specific errors, e.g., no suitable hardware found.
      debugPrint('Error checking biometrics: $e');
      canCheckBiometrics = false;
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  // Gets the list of available biometric types (e.g., fingerprint, face, iris).
  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics = [];
    try {
      availableBiometrics = await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      // Handle platform-specific errors.
      debugPrint('Error getting available biometrics: $e');
      availableBiometrics = [];
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  // Initiates biometric authentication.
  Future<void> _authenticate() async {
    bool authenticated = false;
    setState(() {
      _isAuthenticating = true;
      _authorizedStatus = 'Authenticating...';
    });

    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the secret content',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep the authentication dialog visible until dismissed.
          // biometricOnly: true, // Optional: only allow biometrics, no device PIN/pattern.
        ),
      );
    } on PlatformException catch (e) {
      // Handle various platform exceptions during authentication.
      debugPrint('Error during authentication: $e');
      if (e.code == 'PasscodeNotSet') {
        _authorizedStatus = 'Passcode not set on device.';
      } else if (e.code == 'NotAvailable') {
        _authorizedStatus = 'Biometrics not available.';
      } else if (e.code == 'NotEnrolled') {
        _authorizedStatus = 'No biometrics enrolled.';
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        _authorizedStatus = 'Biometrics locked. Try again later or use device PIN.';
      } else if (e.code == 'AuthError') {
        _authorizedStatus = 'Authentication error. Please try again.';
      }
      authenticated = false;
    }

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _authorizedStatus = authenticated ? 'Authorized SUCCESS' : 'Authorized FAILED';
    });
  }

  // Stops any ongoing biometric authentication.
  Future<void> _cancelAuthentication() async {
    await _localAuth.stopAuthentication();
    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
      _authorizedStatus = 'Authentication Cancelled';
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Authentication'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                Icons.fingerprint,
                size: 100,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Biometric Status',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildStatusTile(
                context,
                'Can check biometrics:',
                _canCheckBiometrics ? 'Yes' : 'No',
                _canCheckBiometrics ? Icons.check_circle_outline : Icons.cancel_outlined,
                _canCheckBiometrics ? Colors.green : Colors.red,
              ),
              _buildStatusTile(
                context,
                'Available biometrics:',
                _availableBiometrics.isNotEmpty
                    ? _availableBiometrics.map((e) => e.name).join(', ')
                    : 'None',
                _availableBiometrics.isNotEmpty ? Icons.fingerprint_rounded : Icons.block,
                _availableBiometrics.isNotEmpty ? Colors.blue : Colors.grey,
              ),
              _buildStatusTile(
                context,
                'Authorization status:',
                _authorizedStatus,
                _authorizedStatus == 'Authorized SUCCESS'
                    ? Icons.lock_open_rounded
                    : Icons.lock_rounded,
                _authorizedStatus == 'Authorized SUCCESS'
                    ? Colors.green
                    : (_authorizedStatus == 'Not Authorized' || _authorizedStatus == 'Authenticating...')
                        ? Colors.orange
                        : Colors.red,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isAuthenticating ? null : _authenticate,
                icon: const Icon(Icons.fingerprint_outlined),
                label: Text(
                  _isAuthenticating ? 'Authenticating...' : 'Authenticate Now',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
              if (_isAuthenticating) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _cancelAuthentication,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Authentication'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: textTheme.titleMedium,
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant),
              const SizedBox(height: 24),
              Text(
                'Developer Tools',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _checkBiometrics,
                icon: const Icon(Icons.refresh),
                label: const Text('Re-check Biometrics'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _getAvailableBiometrics,
                icon: const Icon(Icons.list),
                label: const Text('Re-get Available Biometrics'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTile(
      BuildContext context, String title, String value, IconData icon, Color iconColor) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
