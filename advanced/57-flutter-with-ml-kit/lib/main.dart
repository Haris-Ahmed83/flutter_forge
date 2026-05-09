import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:io'; // Required for File class to display images

/// The main entry point for the Flutter application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the application, configuring themes and navigation.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Kit Vision App',
      theme: ThemeData(
        // Enable Material 3 design.
        useMaterial3: true,
        // Define the color scheme for the app based on a seed color.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Configure app bar theme for consistent styling.
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          centerTitle: true,
          elevation: 4,
        ),
        // Configure card theme for consistent styling and visual appeal.
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        // Configure text theme for consistent typography.
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      home: const MLKitVisionPage(),
    );
  }
}

/// A StatefulWidget that handles image selection, processing with ML Kit,
/// and displaying the results for text recognition and image labeling.
class MLKitVisionPage extends StatefulWidget {
  const MLKitVisionPage({super.key});

  @override
  State<MLKitVisionPage> createState() => _MLKitVisionPageState();
}

class _MLKitVisionPageState extends State<MLKitVisionPage> {
  // Stores the currently picked image file. Null if no image is picked.
  XFile? _pickedImageFile;
  // Stores the recognized text from the image. Null if not processed or no text found.
  String? _recognizedText;
  // Stores the list of image labels. Empty if not processed or no labels found.
  List<ImageLabel> _imageLabels = [];
  // Flag to indicate if an image is currently being processed by ML Kit.
  bool _isProcessing = false;

  // ML Kit Text Recognizer instance.
  // Initialized in initState and closed in dispose.
  late final TextRecognizer _textRecognizer;
  // ML Kit Image Labeler instance.
  // Initialized in initState and closed in dispose.
  late final ImageLabeler _imageLabeler;

  @override
  void initState() {
    super.initState();
    // Initialize the TextRecognizer for Latin script.
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    // Initialize the ImageLabeler with default options (on-device model).
    _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
  }

  @override
  void dispose() {
    // Release resources held by the recognizers when the widget is disposed
    // to prevent memory leaks.
    _textRecognizer.close();
    _imageLabeler.close();
    super.dispose();
  }

  /// Handles picking an image from either the gallery or camera.
  /// Sets the picked image and triggers ML Kit processing.
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    setState(() {
      _isProcessing = true; // Show loading indicator
      _pickedImageFile = null; // Clear previous image
      _recognizedText = null; // Clear previous text results
      _imageLabels = []; // Clear previous label results
    });

    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _pickedImageFile = image; // Update the UI with the new image
        });
        await _processImage(image); // Process the newly picked image
      } else {
        // If user cancels image picking, stop processing state.
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      // Show error message if image picking fails.
      _showSnackBar('Failed to pick image: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Orchestrates the ML Kit processing for a given image file.
  /// Calls both text recognition and image labeling.
  Future<void> _processImage(XFile imageFile) async {
    setState(() {
      _isProcessing = true; // Set processing flag
      _recognizedText = null; // Clear previous results
      _imageLabels = [];
    });

    try {
      // Create an InputImage from the picked XFile path.
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      // Perform text recognition asynchronously.
      final String text = await _recognizeText(inputImage);
      // Perform image labeling asynchronously.
      final List<ImageLabel> labels = await _labelImage(inputImage);

      setState(() {
        // Update state with results. Provide a default message if no text/labels found.
        _recognizedText = text.isNotEmpty ? text : 'No text recognized.';
        _imageLabels = labels.isNotEmpty ? labels : [];
      });
    } catch (e) {
      // Catch any errors during ML Kit processing and display a snackbar.
      _showSnackBar('Error processing image: $e');
      setState(() {
        _recognizedText = 'Error: $e';
        _imageLabels = [];
      });
    } finally {
      setState(() {
        _isProcessing = false; // Reset processing flag
      });
    }
  }

  /// Performs text recognition on the given InputImage using the initialized recognizer.
  /// Returns the concatenated recognized text.
  Future<String> _recognizeText(InputImage inputImage) async {
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    // Return the full text string extracted from the image.
    return recognizedText.text;
  }

  /// Performs image labeling on the given InputImage using the initialized labeler.
  /// Returns a list of ImageLabel objects.
  Future<List<ImageLabel>> _labelImage(InputImage inputImage) async {
    return await _imageLabeler.processImage(inputImage);
  }

  /// Displays a SnackBar with the given message.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Kit Vision Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Section for image input buttons (Gallery and Camera).
              _buildImageSelectionButtons(context),
              const SizedBox(height: 24),

              // Display the picked image or a placeholder if none selected.
              _pickedImageFile == null
                  ? _buildNoImagePlaceholder(context)
                  : _buildImagePreview(context),
              const SizedBox(height: 24),

              // Show a loading indicator while ML Kit is processing.
              if (_isProcessing)
                Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              if (_isProcessing) const SizedBox(height: 24),

              // Display Text Recognition results in a card.
              _buildTextRecognitionCard(textTheme, colorScheme),
              const SizedBox(height: 16),

              // Display Image Labeling results in a card.
              _buildImageLabelingCard(textTheme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the section containing buttons for picking images from gallery or camera.
  Widget _buildImageSelectionButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Select Image for Analysis',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    // Disable button if an image is currently being processed.
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    // Disable button if an image is currently being processed.
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a placeholder widget displayed when no image has been picked yet.
  Widget _buildNoImagePlaceholder(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No image selected',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pick an image from your gallery or take a new one to start ML Kit analysis.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the widget to display the picked image.
  Widget _buildImagePreview(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded with card.
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selected Image Preview',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 250, // Fixed height for consistent image preview size.
            width: double.infinity,
            child: Image.file(
              File(_pickedImageFile!.path), // Display the image from its file path.
              fit: BoxFit.cover, // Cover the box while maintaining aspect ratio.
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(height: 16), // Padding below the image
        ],
      ),
    );
  }

  /// Builds the card to display text recognition results.
  Widget _buildTextRecognitionCard(TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Text Recognition Results',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
            ),
            const Divider(height: 24),
            if (_recognizedText == null && !_isProcessing)
              Text(
                'No text processed yet.',
                style: textTheme.bodyMedium,
              )
            else if (_recognizedText != null)
              // Display recognized text.
              Text(
                _recognizedText!,
                style: textTheme.bodyLarge,
              )
            else
              Text(
                'Processing text...',
                style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the card to display image labeling results.
  Widget _buildImageLabelingCard(TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Image Labeling Results',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
            ),
            const Divider(height: 24),
            if (_imageLabels.isEmpty && !_isProcessing)
              Text(
                'No labels processed yet.',
                style: textTheme.bodyMedium,
              )
            else if (_imageLabels.isNotEmpty)
              // Use Wrap to display chips for each label, allowing flexible layout.
              Wrap(
                spacing: 8.0, // Horizontal spacing between chips
                runSpacing: 8.0, // Vertical spacing between rows of chips
                children: _imageLabels.map((label) {
                  return Chip(
                    label: Text(
                      // Display label text and confidence score.
                      '${label.text} (${(label.confidence * 100).toStringAsFixed(1)}%)',
                      style: textTheme.labelLarge?.copyWith(color: colorScheme.onSecondaryContainer),
                    ),
                    backgroundColor: colorScheme.secondaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  );
                }).toList(),
              )
            else
              Text(
                'Processing labels...',
                style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
