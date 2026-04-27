import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// --- MAIN APP ENTRY POINT ---
void main() {
  runApp(const MyApp());
}

// --- MAIN APPLICATION WIDGET ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps & Location App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const MapScreen(),
    );
  }
}

// --- MAP SCREEN WIDGET ---
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Completer for the GoogleMapController, allows async access once map is created.
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  // Current geographical position of the device.
  Position? _currentPosition;

  // Set of markers to display on the map.
  final Set<Marker> _markers = {};

  // Flag to indicate if location data is being loaded.
  bool _isLoadingLocation = true;

  // Flag to indicate if location permission has been granted.
  bool _locationPermissionGranted = false;

  // Default camera position when the app starts, before user's location is known.
  // Using San Francisco as a placeholder.
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco coordinates
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _checkAndGetLocation();
  }

  // Checks location permissions and fetches the current location.
  Future<void> _checkAndGetLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    LocationPermission permission;
    bool serviceEnabled;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue.
      if (mounted) {
        _showSnackBar('Location services are disabled. Please enable them.');
      }
      setState(() {
        _isLoadingLocation = false;
        _locationPermissionGranted = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try requesting permissions again.
        if (mounted) {
          _showSnackBar('Location permissions are denied.');
        }
        setState(() {
          _isLoadingLocation = false;
          _locationPermissionGranted = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (mounted) {
        _showSnackBar('Location permissions are permanently denied. Please enable them from settings.');
      }
      setState(() {
        _isLoadingLocation = false;
        _locationPermissionGranted = false;
      });
      return;
    }

    // If permissions are granted, get the current position.
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _getCurrentLocation();
    }
  }

  // Fetches the current device location and updates the map.
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
      _updateMarkerAndCamera();
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error getting location: $e');
      }
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Updates the map marker and camera position to the current location.
  Future<void> _updateMarkerAndCamera() async {
    if (_currentPosition == null) return;

    final latLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    setState(() {
      _markers.clear(); // Clear existing markers
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: latLng,
          infoWindow: InfoWindow(
            title: 'My Current Location',
            snippet: 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    });

    // Animate camera to the new position if the map controller is ready.
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 15), // Zoom in a bit
        ),
      );
    }
  }

  // Shows a SnackBar message.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Location Map'),
      ),
      body: Stack(
        children: <Widget>[
          // Main Google Map widget
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            myLocationEnabled: _locationPermissionGranted, // Shows blue dot for user location
            myLocationButtonEnabled: false, // We'll use a custom FAB for this
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              // If location is already known, update camera after map is created.
              if (_currentPosition != null) {
                _updateMarkerAndCamera();
              }
            },
            // TODO: Add your Google Maps API key to your AndroidManifest.xml and Info.plist
            // Android: <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY"/>
            // iOS: <key>com.google.maps.API_KEY</key><string>YOUR_API_KEY</string>
            // Without the API key, the map will not load.
          ),

          // Overlay for displaying current location details
          if (_currentPosition != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'Current Location:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        Text(
                          'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (_isLoadingLocation)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Message for denied permissions
          if (!_locationPermissionGranted && !_isLoadingLocation)
            Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'Location permission denied.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please grant location access to view your current position on the map.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _checkAndGetLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Location'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      // Floating action button to re-center the map on the current location
      floatingActionButton: _locationPermissionGranted && _currentPosition != null
          ? FloatingActionButton(
              onPressed: _updateMarkerAndCamera,
              child: const Icon(Icons.my_location),
            )
          : null, // Hide FAB if permissions not granted or no location
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Info',
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About This App'),
                    content: const Text(
                      'This app demonstrates Google Maps and Geolocator integration in Flutter. '
                      'It fetches your current location and displays it on a map with a marker.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
