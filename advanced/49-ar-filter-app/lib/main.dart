import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_datatypes.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart'; // For Vector3

// -----------------------------------------------------------------------------
// AR Filter App - Single File Example (lib/main.dart)
// -----------------------------------------------------------------------------
// This application demonstrates basic ARCore/ARKit functionality using the
// `ar_flutter_plugin`. It allows users to detect horizontal and vertical planes
// and place 3D models (filters) on them.
//
// To run this app, you need to:
//
// 1. Add `ar_flutter_plugin` to your `pubspec.yaml`:
//    dependencies:
//      flutter:
//        sdk: flutter
//      ar_flutter_plugin: ^0.8.0 # Use the latest stable version
//      # For vector_math_64, which is a transitive dependency of ar_flutter_plugin,
//      # ensure it's available or add it explicitly if you encounter issues:
//      # vector_math: ^2.1.4
//
// 2. Add sample 3D models (e.g., GLB files) to your project.
//    Create an `assets/models/` directory and place your `.glb` files there.
//    Then, reference them in `pubspec.yaml`:
//    flutter:
//      assets:
//        - assets/models/chicken_model.glb
//        - assets/models/hat_model.glb
//        # Add any other models you define in _filterModels
//
// 3. Configure Android (for ARCore):
//    - In `android/app/src/main/AndroidManifest.xml`, add inside `<application>` tag:
//      <meta-data android:name="com.google.ar.core" android:value="true" />
//    - Ensure `minSdkVersion` in `android/app/build.gradle` is at least 24.
//
// 4. Configure iOS (for ARKit):
//    - In `ios/Runner/Info.plist`, add a privacy description for camera usage:
//      <key>NSCameraUsageDescription</key>
//      <string>Camera access is needed for Augmented Reality features to place virtual objects in your real world.</string>
//    - Ensure `platform :ios, '11.0'` or higher in `ios/Podfile`.
//
// 5. Run `flutter pub get` after modifying `pubspec.yaml`.
// -----------------------------------------------------------------------------

void main() {
  runApp(const ARFilterApp());
}

class ARFilterApp extends StatelessWidget {
  const ARFilterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Filter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, // Dark theme for a modern look
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          scrolledUnderElevation: 0, // No shadow when scrolled
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      home: const ARFilterHomePage(),
    );
  }
}

class ARFilterHomePage extends StatefulWidget {
  const ARFilterHomePage({super.key});

  @override
  State<ARFilterHomePage> createState() => _ARFilterHomePageState();
}

class _ARFilterHomePageState extends State<ARFilterHomePage> {
  // AR session managers responsible for different aspects of the AR experience.
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;

  // Lists to keep track of placed AR anchors (locations) and nodes (3D objects).
  List<ARAnchor> anchors = [];
  List<ARNode> nodes = [];

  // Currently selected 3D model asset path to be placed on a tap.
  String _selectedFilterModel = 'assets/models/chicken_model.glb';

  // Map of available filter names to their corresponding 3D model asset paths.
  final Map<String, String> _filterModels = {
    'Chicken': 'assets/models/chicken_model.glb',
    'Hat': 'assets/models/hat_model.glb',
    // TODO: Add more models here. Ensure these GLB files are in your assets folder
    // and referenced in pubspec.yaml. Example: 'assets/models/glasses_model.glb'
  };

  @override
  void dispose() {
    // Dispose the AR session manager when the widget is removed to release resources.
    arSessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Filter Fun'),
      ),
      body: Stack(
        children: [
          // ARView widget takes up the entire screen to display the camera feed and AR content.
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            showFeaturePoints: true, // Show feature points for debugging plane detection.
            showWorldOrigin: true, // Show world origin for reference.
            keepDeviceAwake: true, // Prevent device from sleeping during AR session.
          ),
          // Overlay UI for filter selection and actions (positioned at the bottom).
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row of buttons for selecting different AR filters.
                  _buildFilterSelectionRow(),
                  const SizedBox(height: 16),
                  // Row of action buttons (clear all, take screenshot).
                  _buildActionButtonsRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the horizontal row of ChoiceChips for selecting different AR filters.
  Widget _buildFilterSelectionRow() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _filterModels.entries.map((entry) {
            final filterName = entry.key;
            final modelPath = entry.value;
            final isSelected = _selectedFilterModel == modelPath;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(filterName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedFilterModel = modelPath; // Update the selected model.
                    });
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Builds the row of action buttons (Clear All, Screenshot).
  Widget _buildActionButtonsRow() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _onClearButtonPressed,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _onScreenshotButtonPressed,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Screenshot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Callback function executed when the ARView is created and managers are initialized.
  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
  ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    // Initialize AR session settings.
    this.arSessionManager.onInitialize(
          showFeaturePoints: true,
          showPlanes: true,
          customPlaneTexturePath:
              "assets/triangle.png", // Optional: Custom texture for detected planes.
          showWorldOrigin: true,
        );
    this.arObjectManager.onInitialize();

    // Register a callback for when a plane is tapped to place objects.
    this.arSessionManager.onPlaneTap = _onPlaneTap;
    // Register a callback for when an object is tapped (optional, not fully implemented here).
    this.arObjectManager.onNodeTap = (List<String> nodes) => _onNodeTap(nodes);
  }

  // Handles plane tap events: places the currently selected 3D object on the tapped plane.
  Future<void> _onPlaneTap(List<ARHitTestResult> hitResults) async {
    // Find the first valid hit test result that corresponds to a detected plane.
    var singleHitTestResult = hitResults.firstWhereOrNull(
      (hitTestResult) =>
          hitTestResult.type == ARHitTestResultType.planeUsingGameEngineFeaturePoint ||
          hitTestResult.type == ARHitTestResultType.planeUsingExtent,
    );

    if (singleHitTestResult != null) {
      // Create a new AR anchor at the tapped location on the plane.
      var newAnchor = ARPlaneAnchor(
        transformation: singleHitTestResult.worldTransform,
        ttl: 0, // Anchor lives indefinitely.
      );
      bool? didAddAnchor = await arAnchorManager.addAnchor(newAnchor);

      if (didAddAnchor != null && didAddAnchor) {
        // Create an AR node (3D object) using the selected model and attach it to the anchor.
        var newNode = ARNode(
          type: NodeType.fileSystem,
          uri: _selectedFilterModel, // Use the currently selected model.
          scale: Vector3(0.2, 0.2, 0.2), // Adjust scale as needed for the model.
          position: Vector3(0, 0, 0), // Position relative to the anchor.
          rotation: Vector4(1.0, 0.0, 0.0, 0.0), // No initial rotation.
        );
        bool? didAddNodeToAnchor =
            await arObjectManager.addNode(newNode, anchor: newAnchor);

        if (didAddNodeToAnchor != null && didAddNodeToAnchor) {
          // Keep track of the added anchor and node for future management (e.g., clearing).
          anchors.add(newAnchor);
          nodes.add(newNode);
        } else {
          // If node couldn't be added, remove the anchor to clean up.
          arAnchorManager.removeAnchor(newAnchor);
          _showSnackBar('Failed to place object.', isError: true);
        }
      } else {
        _showSnackBar('Failed to detect a plane to place object.', isError: true);
      }
    }
  }

  // Handles object tap events (currently provides a message, can be extended for interaction).
  void _onNodeTap(List<String> nodes) {
    // This callback is triggered when an AR node is tapped.
    // You could implement logic here to interact with the tapped node,
    // e.g., change its color, scale, or remove it.
    _showSnackBar('Tapped on node(s): ${nodes.join(', ')}');
  }

  // Clears all placed AR objects (nodes and their anchors) from the scene.
  Future<void> _onClearButtonPressed() async {
    for (var anchor in anchors) {
      await arAnchorManager.removeAnchor(anchor);
    }
    anchors.clear();
    nodes.clear();
    _showSnackBar('All objects cleared!');
  }

  // Takes a screenshot of the current AR view.
  Future<void> _onScreenshotButtonPressed() async {
    try {
      var image = await arSessionManager.snapshot();
      if (image != null) {
        // In a real app, you would save this image to the gallery
        // or share it. For this example, we'll just log its path.
        _showSnackBar('Screenshot captured! Path: ${image.path}');
        // TODO: Implement saving image to gallery or sharing functionality.
        // You might need a package like `image_gallery_saver` or `share_plus`.
        // Example:
        // await ImageGallerySaver.saveFile(image.path);
        // _showSnackBar('Screenshot saved to gallery!');
      } else {
        _showSnackBar('Failed to capture screenshot.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error capturing screenshot: $e', isError: true);
    }
  }

  // Helper function to show a SnackBar message at the bottom of the screen.
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating, // Makes the SnackBar float above content.
      ),
    );
  }
}

// Extension to provide `firstWhereOrNull` which is similar to the method
// found in the `collection` package, useful for safely getting the first element
// that matches a condition or null if none is found.
extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
