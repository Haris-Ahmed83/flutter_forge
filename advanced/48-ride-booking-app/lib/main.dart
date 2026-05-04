import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// --- STUB FOR PUBSPEC.YAML ---
// Add the following to your pubspec.yaml under dependencies:
// google_maps_flutter: ^2.5.0 # Use the latest stable version
// -----------------------------

// --- STUB FOR PLATFORM SETUP ---
// For Android:
// Add your Google Maps API key to your AndroidManifest.xml:
// <manifest ...>
//   <application ...>
//     <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY"/>
//   </application>
// </manifest>
//
// For iOS:
// Add your Google Maps API key to your Info.plist:
// <key>GoogleMapsAPIKey</key>
// <string>YOUR_API_KEY</string>
//
// Also, enable the Google Maps SDK for iOS in your Podfile:
// platform :ios, '13.0' # Or higher
// target 'Runner' do
//   use_frameworks!
//   flutter_install_all_ios_pods_for_target(self)
//   pod 'GoogleMaps', '~> 6.0' # Or latest stable version
// end
//
// Remember to run `flutter clean` and `flutter pub get` after modifying pubspec.yaml
// and `cd ios && pod install` after modifying Podfile.
// ---------------------------------

void main() {
  runApp(const RideBookingApp());
}

/// Enum to represent the different stages of a ride.
enum RideStatus {
  idle, // No ride requested
  searching, // Looking for a driver
  driverEnRoute, // Driver is on their way
  arrived, // Driver has arrived at pickup location
  inProgress, // Ride is ongoing
  completed, // Ride finished
  cancelled, // Ride cancelled
}

/// Main application widget.
class RideBookingApp extends StatelessWidget {
  const RideBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Booking App',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal, // A pleasant base color for Material 3
        useMaterial3: true,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const RideBookingHomePage(),
    );
  }
}

/// Home page of the ride booking app, displaying the map and ride controls.
class RideBookingHomePage extends StatefulWidget {
  const RideBookingHomePage({super.key});

  @override
  State<RideBookingHomePage> createState() => _RideBookingHomePageState();
}

class _RideBookingHomePageState extends State<RideBookingHomePage> {
  GoogleMapController? _mapController;

  // Default user location (e.g., a city center)
  static const LatLng _userLocation = LatLng(37.7749, -122.4194); // San Francisco
  // Default destination location
  static const LatLng _destinationLocation = LatLng(37.7913, -122.3995); // Near Ferry Building

  // Initial driver location (simulated, slightly away from user)
  LatLng _driverLocation = const LatLng(37.7600, -122.4500);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Stream controllers for real-time updates
  final StreamController<LatLng> _driverLocationStreamController =
      StreamController<LatLng>.broadcast();
  final StreamController<RideStatus> _rideStatusStreamController =
      StreamController<RideStatus>.broadcast();

  Timer? _driverMovementTimer; // Timer to simulate driver movement
  RideStatus _currentRideStatus = RideStatus.idle;

  @override
  void initState() {
    super.initState();
    _rideStatusStreamController.add(_currentRideStatus); // Initialize status stream

    // Listen to driver location stream and update marker
    _driverLocationStreamController.stream.listen((newLocation) {
      if (mounted) {
        setState(() {
          _driverLocation = newLocation;
          _updateMarkers(); // Update markers when driver location changes
        });
      }
    });

    // Listen to ride status stream and update UI
    _rideStatusStreamController.stream.listen((status) {
      if (mounted) {
        setState(() {
          _currentRideStatus = status;
          if (status == RideStatus.driverEnRoute) {
            _startDriverMovementSimulation(); // Start driver movement when en route
          } else {
            _stopDriverMovementSimulation(); // Stop when not en route
          }
          _updateMarkers(); // Update markers based on status (e.g., hide destination if not booked)
        });
      }
    });

    _updateMarkers(); // Set initial markers
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _driverLocationStreamController.close();
    _rideStatusStreamController.close();
    _driverMovementTimer?.cancel();
    super.dispose();
  }

  /// Called when the Google Map is created.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Animate camera to show both user and driver initially
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            min(_userLocation.latitude, _driverLocation.latitude),
            min(_userLocation.longitude, _driverLocation.longitude),
          ),
          northeast: LatLng(
            max(_userLocation.latitude, _driverLocation.latitude),
            max(_userLocation.longitude, _driverLocation.longitude),
          ),
        ),
        100.0, // Padding
      ),
    );
  }

  /// Updates the set of markers displayed on the map.
  void _updateMarkers() {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('userLocation'),
        position: _userLocation,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Only show driver marker if a ride is in progress or driver is en route
    if (_currentRideStatus == RideStatus.driverEnRoute ||
        _currentRideStatus == RideStatus.arrived ||
        _currentRideStatus == RideStatus.inProgress) {
      _markers.add(
        Marker(
          markerId: const MarkerId('driverLocation'),
          position: _driverLocation,
          infoWindow: const InfoWindow(title: 'Your Driver'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    // Only show destination marker if a ride is booked or in progress
    if (_currentRideStatus != RideStatus.idle && _currentRideStatus != RideStatus.searching) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destinationLocation'),
          position: _destinationLocation,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Update polylines based on ride status
    _updatePolylines();
  }

  /// Updates the set of polylines displayed on the map.
  void _updatePolylines() {
    _polylines.clear();
    if (_currentRideStatus == RideStatus.driverEnRoute) {
      // Driver to user path
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('driverToUser'),
          points: [_driverLocation, _userLocation],
          color: Colors.blue.shade700,
          width: 5,
        ),
      );
    } else if (_currentRideStatus == RideStatus.inProgress) {
      // User to destination path
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('userToDestination'),
          points: [_userLocation, _destinationLocation],
          color: Colors.purple.shade700,
          width: 5,
        ),
      );
    }
  }

  /// Simulates the driver moving towards a target location.
  void _startDriverMovementSimulation() {
    _driverMovementTimer?.cancel(); // Cancel any existing timer
    _driverMovementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      LatLng targetLocation;
      if (_currentRideStatus == RideStatus.driverEnRoute) {
        targetLocation = _userLocation; // Driver moves towards user
      } else if (_currentRideStatus == RideStatus.inProgress) {
        targetLocation = _destinationLocation; // Driver moves towards destination
      } else {
        timer.cancel(); // Stop simulation if status is not relevant
        return;
      }

      // Simple linear interpolation for movement
      final double lat = lerp(_driverLocation.latitude, targetLocation.latitude, 0.05);
      final double lng = lerp(_driverLocation.longitude, targetLocation.longitude, 0.05);
      final LatLng newDriverPos = LatLng(lat, lng);

      // Check if driver has "arrived"
      if (_currentRideStatus == RideStatus.driverEnRoute &&
          _isNear(_driverLocation, _userLocation, 0.001)) {
        _rideStatusStreamController.add(RideStatus.arrived);
        _driverLocationStreamController.add(_userLocation); // Snap driver to user location
        timer.cancel(); // Stop driver movement for now
      } else if (_currentRideStatus == RideStatus.inProgress &&
          _isNear(_driverLocation, _destinationLocation, 0.001)) {
        _rideStatusStreamController.add(RideStatus.completed);
        _driverLocationStreamController.add(_destinationLocation); // Snap driver to destination
        timer.cancel(); // Stop driver movement for now
      } else {
        _driverLocationStreamController.add(newDriverPos); // Emit new driver location
      }
    });
  }

  /// Stops the driver movement simulation.
  void _stopDriverMovementSimulation() {
    _driverMovementTimer?.cancel();
  }

  /// Linear interpolation helper.
  double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Checks if two LatLng points are within a certain distance (epsilon).
  bool _isNear(LatLng p1, LatLng p2, double epsilon) {
    return (p1.latitude - p2.latitude).abs() < epsilon &&
        (p1.longitude - p2.longitude).abs() < epsilon;
  }

  /// Handles the "Book Ride" button press.
  Future<void> _bookRide() async {
    _rideStatusStreamController.add(RideStatus.searching);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_userLocation, 14.0));

    await Future.delayed(const Duration(seconds: 3)); // Simulate searching for driver
    _rideStatusStreamController.add(RideStatus.driverEnRoute);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            min(_userLocation.latitude, _driverLocation.latitude),
            min(_userLocation.longitude, _driverLocation.longitude),
          ),
          northeast: LatLng(
            max(_userLocation.latitude, _driverLocation.latitude),
            max(_userLocation.longitude, _driverLocation.longitude),
          ),
        ),
        100.0,
      ),
    );

    await Future.delayed(const Duration(seconds: 15)); // Simulate driver arrival
    if (_currentRideStatus == RideStatus.driverEnRoute) {
      _rideStatusStreamController.add(RideStatus.arrived);
    }
  }

  /// Handles the "Start Ride" button press.
  void _startRide() {
    _rideStatusStreamController.add(RideStatus.inProgress);
    _driverLocationStreamController.add(_userLocation); // Driver starts from user's location
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            min(_userLocation.latitude, _destinationLocation.latitude),
            min(_userLocation.longitude, _destinationLocation.longitude),
          ),
          northeast: LatLng(
            max(_userLocation.latitude, _destinationLocation.latitude),
            max(_userLocation.longitude, _destinationLocation.longitude),
          ),
        ),
        100.0,
      ),
    );
  }

  /// Handles the "Cancel Ride" button press.
  void _cancelRide() {
    _rideStatusStreamController.add(RideStatus.cancelled);
    _stopDriverMovementSimulation();
    // Reset driver location to initial simulated position
    setState(() {
      _driverLocation = const LatLng(37.7600, -122.4500);
    });
    // After a short delay, go back to idle
    Future.delayed(const Duration(seconds: 2), () {
      _rideStatusStreamController.add(RideStatus.idle);
    });
  }

  /// Returns the appropriate UI for the current ride status.
  Widget _buildRideStatusUI() {
    switch (_currentRideStatus) {
      case RideStatus.idle:
        return _buildIdleUI();
      case RideStatus.searching:
        return _buildSearchingUI();
      case RideStatus.driverEnRoute:
        return _buildDriverEnRouteUI();
      case RideStatus.arrived:
        return _buildArrivedUI();
      case RideStatus.inProgress:
        return _buildInProgressUI();
      case RideStatus.completed:
        return _buildCompletedUI();
      case RideStatus.cancelled:
        return _buildCancelledUI();
    }
  }

  Widget _buildIdleUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Ready for a ride?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _bookRide,
          icon: const Icon(Icons.drive_eta),
          label: const Text('Book a Ride'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchingUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        const Text(
          'Searching for a driver...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _cancelRide,
          icon: const Icon(Icons.cancel),
          label: const Text('Cancel Ride'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverEnRouteUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.car_crash, size: 40, color: Colors.green),
        const SizedBox(height: 8),
        Text(
          'Driver en route! ${_driverLocation.latitude.toStringAsFixed(4)}, ${_driverLocation.longitude.toStringAsFixed(4)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Estimated arrival: 5 mins',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Implement call driver
              },
              icon: const Icon(Icons.call),
              label: const Text('Call Driver'),
            ),
            ElevatedButton.icon(
              onPressed: _cancelRide,
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArrivedUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, size: 40, color: Colors.green),
        const SizedBox(height: 8),
        const Text(
          'Your driver has arrived!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _startRide,
          icon: const Icon(Icons.navigation),
          label: const Text('Start Ride'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.alt_route, size: 40, color: Colors.purple),
        const SizedBox(height: 8),
        const Text(
          'Enjoying your ride!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Destination: Ferry Building',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _cancelRide, // Can still cancel mid-ride
          icon: const Icon(Icons.cancel),
          label: const Text('End Ride Early'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.celebration, size: 40, color: Colors.amber),
        const SizedBox(height: 8),
        const Text(
          'Ride Completed!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Thank you for riding with us!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            _rideStatusStreamController.add(RideStatus.idle); // Go back to idle
          },
          icon: const Icon(Icons.home),
          label: const Text('Book Another Ride'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.sentiment_dissatisfied, size: 40, color: Colors.red),
        const SizedBox(height: 8),
        const Text(
          'Ride Cancelled',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          'We hope to see you again soon.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            _rideStatusStreamController.add(RideStatus.idle); // Go back to idle
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride App'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _userLocation,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true, // Simulate current location
            myLocationButtonEnabled: false, // Hide default button
            zoomControlsEnabled: false, // Hide default zoom controls for cleaner UI
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: StreamBuilder<RideStatus>(
                    stream: _rideStatusStreamController.stream,
                    initialData: RideStatus.idle,
                    builder: (context, snapshot) {
                      return _buildRideStatusUI();
                    },
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
