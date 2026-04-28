// pubspec.yaml dependencies required:
// flutter_pdfview: ^1.2.0
// http: ^1.1.0
// path_provider: ^2.1.1
// path: ^1.8.3

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey, // Material 3 dynamic color generation
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const PdfViewerPage(),
    );
  }
}

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _pdfPath; // Path to the downloaded PDF file
  bool _isLoading = true; // Loading state for download and initial PDF setup
  String? _errorMessage; // Stores any error messages
  int _pages = 0; // Total number of pages in the PDF
  int _currentPage = 0; // Current page number (0-indexed)
  bool _pdfReady = false; // Indicates if the PDF is fully rendered and ready for interaction

  // Sample PDF URL for demonstration. Replace with your own or a local asset.
  // For production, consider using a more robust PDF source (e.g., from an API or local storage).
  static const String _samplePdfUrl =
      'https://www.africau.edu/images/default/sample.pdf';

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  /// Downloads a sample PDF from a URL to the app's temporary directory
  /// and updates the [_pdfPath] state variable.
  Future<void> _downloadAndLoadPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(_samplePdfUrl));
      if (response.statusCode == 200) {
        // Get the application's temporary directory for storing the PDF
        final directory = await getTemporaryDirectory();
        // Create a unique file path for the PDF within the temporary directory
        final file = File(p.join(directory.path, 'sample.pdf'));
        // Write the downloaded bytes to the file
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _pdfPath = file.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to download PDF: Status code ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error downloading PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: Stack(
        children: <Widget>[
          // Display PDF if path is available and no error
          if (_pdfPath != null && _errorMessage == null)
            PDFView(
              filePath: _pdfPath!,
              enableSwipe: true,
              swipeHorizontal: false, // Vertical scrolling
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: _currentPage,
              fitPolicy: FitPolicy.WIDTH, // Fit PDF to screen width
              preventLinkNavigation: false,
              onRender: (_pages) {
                // Called when PDF is fully rendered for the first time
                setState(() {
                  this._pages = _pages ?? 0;
                  _pdfReady = true;
                });
              },
              onViewCreated: (PDFViewController pdfViewController) {
                // Controller can be stored if needed for programmatic page changes
                // _pdfViewController = pdfViewController;
              },
              onPageChanged: (int? page, int? total) {
                // Called when page is changed by user swipe or programmatic change
                setState(() {
                  _currentPage = page ?? 0;
                });
              },
              onError: (error) {
                // Handle general errors during PDF loading/rendering
                setState(() {
                  _errorMessage = 'Error loading PDF: $error';
                  _isLoading = false;
                });
                debugPrint('PDFView Error: ${error.toString()}');
              },
              onPageError: (page, error) {
                // Handle errors that occur on a specific page
                setState(() {
                  _errorMessage = 'Error on page $page: $error';
                  _isLoading = false;
                });
                debugPrint('Page Error ($page): ${error.toString()}');
              },
            ),

          // Show loading indicator while downloading or initializing PDF
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Downloading PDF...'),
                ],
              ),
            ),

          // Show error message if any, along with a retry button
          if (_errorMessage != null && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        color: Theme.of(context).colorScheme.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _downloadAndLoadPdf,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),

          // Display page number overlay if PDF is ready and not in a loading/error state
          if (_pdfReady && !_isLoading && _errorMessage == null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Page ${_currentPage + 1} of $_pages', // Display 1-indexed page number
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
