🗺️ Maps and Location App
> An intermediate Flutter project demonstrating real-time location tracking and interactive map functionalities.

## Description
This Flutter application serves as an intermediate-level project focused on integrating powerful mapping and location services. It showcases how to leverage Google Maps for interactive map displays and the Geolocator package to retrieve and manage device location data, providing a robust foundation for location-aware mobile apps.

## Features
*   Display interactive and customizable Google Maps.
*   Get the user's current geographical location in real-time.
*   Dynamically update the map camera to follow the user's current position.
*   Request and handle necessary location permissions for both Android and iOS.
*   Mark the user's current location on the map with a custom marker.
*   Listen for continuous location updates as the user moves.

## Key Concepts Demonstrated
*   **Google Maps:** Integration of the `google_maps_flutter` package, displaying interactive maps, controlling the map camera, adding and managing markers, and handling various map events.
*   **Geolocator:** Utilizing the `geolocator` package to access the device's current location, requesting and managing location permissions, and subscribing to real-time location updates.

## Getting Started
To get this project up and running on your local machine, follow these steps:

1.  **Install Dependencies:**
    Navigate to the project directory and install the required packages:
    ```bash
    flutter pub get
    ```
2.  **Google Maps API Key:**
    *   Obtain a Google Maps API key from the [Google Cloud Console](https://console.cloud.google.com/).
    *   Enable the "Maps SDK for Android" and "Maps SDK for iOS" for your project.
    *   Follow the instructions in the `google_maps_flutter` package documentation to add your API key to your Android (`android/app/src/main/AndroidManifest.xml`) and iOS (`ios/Runner/AppDelegate.swift` or `ios/Runner/Info.plist`) projects.
3.  **Run the Application:**
    ```bash
    flutter run
    ```
    Ensure you have an Android emulator, iOS simulator, or a physical device connected and properly configured.

## Screenshots
> Add screenshots here to showcase the application's UI and features, including map views and location updates.

## Author
- HarisAhmed83 - [https://github.com/Haris-Ahmed83](https://github.com/Haris-Ahmed83)

Part of the [flutter_forge](https://github.com/Haris-Ahmed83/flutter_forge) series.
