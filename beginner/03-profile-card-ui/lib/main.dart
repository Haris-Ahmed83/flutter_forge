import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Card',
      // Enable Material 3 design
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProfileCardScreen(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class ProfileCardScreen extends StatelessWidget {
  const ProfileCardScreen({super.key});

  // Sample data for the profile card
  static const String _profileImageUrl = 'https://picsum.photos/id/237/200/300'; // Placeholder image (a random dog)
  static const String _name = 'Jane Doe';
  static const String _title = 'Flutter Developer';
  static const String _email = 'jane.doe@example.com';
  static const String _phone = '+1 (555) 123-4567';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: Center(
        // Center the profile card vertically and horizontally on the screen
        child: SingleChildScrollView(
          // Allows the content to scroll if it overflows (e.g., on small screens)
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0, // Adds a shadow below the card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Rounded corners for the card
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20.0), // Margin around the card
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                // Main column to arrange profile elements vertically
                mainAxisSize: MainAxisSize.min, // Column takes minimum space required by its children
                children: <Widget>[
                  // CircleAvatar for the profile picture
                  CircleAvatar(
                    radius: 60, // Size of the avatar
                    backgroundImage: const NetworkImage(_profileImageUrl), // Load image from URL
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2), // Fallback background color
                    child: Align(
                      alignment: Alignment.bottomRight,
                      // Example of adding a small badge/icon over the avatar
                      child: Icon(Icons.verified_user, color: Theme.of(context).colorScheme.primary, size: 24),
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing below the avatar
                  Text(
                    _name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8), // Spacing below the name
                  Text(
                    _title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const Divider(height: 30, thickness: 1), // A visual separator

                  // Row for email contact information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the items within the row
                    children: <Widget>[
                      Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10), // Spacing between icon and text
                      Text(
                        _email,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Spacing between contact rows

                  // Row for phone contact information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      Text(
                        _phone,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Spacing before social media icons

                  // Row for social media/action icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute space evenly between and around items
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.link, size: 30),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          // TODO: Implement website link action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Website link tapped!')),
                          );
                        },
                        tooltip: 'Visit Website',
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, size: 30),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          // TODO: Implement share profile action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share profile tapped!')),
                          );
                        },
                        tooltip: 'Share Profile',
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, size: 30),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          // TODO: Implement send message action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Send message tapped!')),
                          );
                        },
                        tooltip: 'Send Message',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
