import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

// --- IMPORTANT: Project Setup Notes ---
// For this app to run, you need to add the following dependencies to your pubspec.yaml:
//
// dependencies:
//   flutter:
//     sdk: flutter
//   qr_code_scanner: ^1.0.1 # Use the latest stable version
//   permission_handler: ^11.0.1 # Use the latest stable version
//   url_launcher: ^6.2.1 # Use the latest stable version
//   cupertino_icons: ^1.0.2 # Usually included by default
//
// And also ensure platform-specific permissions are configured:
//
// Android (android/app/src/main/AndroidManifest.xml):
// Add inside the <manifest> tag:
// <uses-permission android:name="android.permission.CAMERA"/>
//
// iOS (ios/Runner/Info.plist):
// Add inside the <dict> tag:
// <key>NSCameraUsageDescription</key>
// <string>This app needs camera access to scan QR codes.</string>
//
// --- End Project Setup Notes ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      home: const QrScannerScreen(),
    );
  }
}

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result; // Stores the last scanned QR code data
  bool _hasCameraPermission = false;
  bool _isScanning = true; // Controls whether the scanner is actively looking for codes

  @override
  void initState() {
    super.initState();
    // Check camera permission when the screen initializes.
    _checkCameraPermission();
  }

  @override
  void dispose() {
    // Dispose the QRViewController when the widget is removed from the tree.
    controller?.dispose();
    super.dispose();
  }

  /// Checks and requests camera permissions using `permission_handler`.
  /// Updates `_hasCameraPermission` state based on the result.
  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final newStatus = await Permission.camera.request();
      setState(() {
        _hasCameraPermission = newStatus.isGranted;
      });
    } else {
      setState(() {
        _hasCameraPermission = status.isGranted;
      });
    }
  }

  /// Handles the creation of the `QRViewController`.
  /// Sets up the listener for scanned data.
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_isScanning && scanData.code != null) {
        // Only process if currently scanning and data is not null.
        setState(() {
          result = scanData;
          _isScanning = false; // Stop scanning after the first successful scan.
          controller.pauseCamera(); // Pause camera to prevent continuous scanning.
        });
      }
    });
  }

  /// Resumes the QR scanner to look for new codes.
  void _scanAgain() {
    setState(() {
      result = null; // Clear previous result.
      _isScanning = true; // Re-enable scanning.
    });
    controller?.resumeCamera(); // Resume camera.
  }

  /// Copies the scanned QR code data to the clipboard.
  Future<void> _copyToClipboard(String data) async {
    await Clipboard.setData(ClipboardData(text: data));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard!')),
      );
    }
  }

  /// Attempts to launch a URL if the scanned data is a valid URL.
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _buildQrView(context),
          ),
          Expanded(
            flex: 1,
            child: _buildResultView(),
          )
        ],
      ),
    );
  }

  /// Builds the camera preview and QR scanner overlay.
  Widget _buildQrView(BuildContext context) {
    if (!_hasCameraPermission) {
      // Show a message and a button to request permission if not granted.
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Camera permission denied.',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkCameraPermission,
              child: const Text('Request Permission'),
            ),
          ],
        ),
      );
    }

    // Show loading indicator while camera is being initialized or if controller is not yet set.
    if (controller == null && _hasCameraPermission && _isScanning) {
      return const Center(child: CircularProgressIndicator());
    }

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).colorScheme.primary,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
      onPermissionSet: (ctrl, p) {
        // This callback is provided by the qr_code_scanner package for its internal permission checks.
        // We already handle permission checking with `permission_handler` for better UX,
        // but it's good to log or show a snackbar if this internal check fails.
        if (!p && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Scanner: Camera permission was not granted.')),
          );
        }
      },
    );
  }

  /// Builds the view to display the scanned result and actions.
  Widget _buildResultView() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      color: colorScheme.surfaceVariant,
      child: Center(
        child: result != null && result!.code != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Scanned Code:',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        result!.code!,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(result!.code!),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                      // Only show 'Open URL' button if the scanned code is a valid URL.
                      if (Uri.tryParse(result!.code ?? '')?.isAbsolute == true)
                        ElevatedButton.icon(
                          onPressed: () => _launchUrl(result!.code!),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open URL'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: _scanAgain,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Scan Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.tertiary,
                          foregroundColor: colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Text(
                _hasCameraPermission ? 'Scan a QR code to see the result here!' : 'Camera permission is required.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
