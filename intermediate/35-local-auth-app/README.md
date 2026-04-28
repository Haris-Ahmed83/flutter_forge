# Local Auth App 🔐
> Secure your app with seamless local authentication using biometrics.

## Description
This Flutter project demonstrates how to integrate local authentication into your application, providing a robust security layer. It utilizes biometrics (fingerprint/face ID) and device passcodes to offer a secure and user-friendly method for protecting sensitive sections of your app.

## Features
*   Implement local authentication using biometrics (fingerprint, face ID).
*   Fallback to device passcode authentication if biometrics are unavailable or fail.
*   Check for the availability of supported authentication methods on the device.
*   Provide clear and informative user feedback during authentication attempts.
*   Simple and intuitive UI to trigger and display authentication status.
*   Cross-platform compatibility for both Android and iOS devices.
*   Handle various authentication outcomes (success, failure, user cancellation).

## Key Concepts Demonstrated
*   **Biometrics:** Implementing secure user authentication via device-specific biometric sensors (e.g., fingerprint scanners, facial recognition). This project shows how to prompt users for biometric verification to grant access.
*   **`local_auth`:** Utilizing the `local_auth` Flutter package, which provides a straightforward API to interact with the underlying operating system's local authentication services. It abstracts away the platform-specific details for checking available authentication types and initiating authentication flows.

## Getting Started
To get a local copy of this project up and running on your development machine, follow these simple steps.

1.  **Navigate to the project directory:**
    ```bash
    cd local_auth_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run
    ```
    Ensure you have a device or emulator with biometrics configured (or a passcode/PIN set) to fully test the authentication features.

## Screenshots
*Add screenshots of the app in action here, showcasing the authentication prompt and success/failure states.*

## Author
- HarisAhmed83 - https://github.com/Haris-Ahmed83

Part of the [flutter_forge](https://github.com/Haris-Ahmed83/flutter_forge) series.
