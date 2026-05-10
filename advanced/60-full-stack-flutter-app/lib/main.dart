import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making HTTP requests from Flutter
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

// --- Backend Configuration ---
// The port for the local Shelf server.
// For mobile/desktop targets, 'localhost' refers to the device/emulator itself.
const int _backendPort = 8080;
const String _backendHost = 'localhost';

// --- Backend Server Logic (runs in a separate Isolate) ---

/// Entry point for the backend server isolate.
/// This function is responsible for setting up and starting the Shelf server.
/// The `message` parameter is expected to be a `SendPort` to communicate back
/// to the main Flutter isolate.
void _startBackendServer(SendPort sendPort) async {
  // Create a Shelf router to define API endpoints.
  final _router = Router();

  // Define a GET endpoint for a greeting.
  // Example: GET /greet?name=FlutterDev
  _router.get('/greet', (Request request) {
    final name = request.url.queryParameters['name'] ?? 'World';
    return Response.ok(jsonEncode({'message': 'Hello, $name from Shelf!'}),
        headers: {'Content-Type': 'application/json'});
  });

  // Define a GET endpoint to retrieve a list of items.
  // This simulates fetching data from a database.
  _router.get('/items', (Request request) {
    final items = [
      {'id': 1, 'name': 'Item A', 'description': 'Description for item A'},
      {'id': 2, 'name': 'Item B', 'description': 'Description for item B'},
      {'id': 3, 'name': 'Item C', 'description': 'Description for item C'},
    ];
    return Response.ok(jsonEncode(items),
        headers: {'Content-Type': 'application/json'});
  });

  // Define a POST endpoint to add a new item.
  // This simulates creating new data in the backend.
  _router.post('/items', (Request request) async {
    try {
      final payload = jsonDecode(await request.readAsString());
      // In a real application, you would typically save `payload` to a database.
      // For this example, we just acknowledge receipt.
      print('Backend received new item: $payload');
      return Response.created('/items/${payload['id'] ?? 'new'}',
          body: jsonEncode({'message': 'Item created', 'data': payload}),
          headers: {'Content-Type': 'application/json'});
    } on FormatException catch (e) {
      return Response.badRequest(
          body: jsonEncode({'error': 'Invalid JSON format: $e'}));
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to process item: $e'}));
    }
  });

  // Fallback handler for any unmatched routes.
  _router.all('/<ignored|.*>', (Request request) {
    return Response.notFound(
        jsonEncode({'error': 'Not Found', 'path': request.url.path}),
        headers: {'Content-Type': 'application/json'});
  });

  // Create a Shelf pipeline with middleware for logging and content type.
  final _handler = Pipeline()
      .addMiddleware(logRequests()) // Logs incoming HTTP requests to the console.
      .addMiddleware(_jsonContentTypeMiddleware) // Ensures JSON content type for responses.
      .addHandler(_router); // Add the router as the final handler.

  try {
    // Start the HTTP server using shelf_io, binding to the specified host and port.
    // HttpServer is available in dart:io, which works on Flutter mobile/desktop
    // but not Flutter web.
    final server = await shelf_io.serve(_handler, _backendHost, _backendPort);
    print('Shelf server running on http://${server.address.host}:${server.port}');
    // Send a message back to the main isolate confirming the server started.
    sendPort.send('Server started on http://${server.address.host}:${server.port}');
  } catch (e) {
    print('Error starting Shelf server: $e');
    // Send an error message back to the main isolate if server fails to start.
    sendPort.send('Error starting server: $e');
  }
}

/// A Shelf middleware that automatically sets the 'Content-Type' header
/// to 'application/json' for all responses, unless already specified.
Middleware _jsonContentTypeMiddleware = (Handler innerHandler) {
  return (Request request) async {
    final response = await innerHandler(request);
    // Only set if not already present.
    if (response.headers['Content-Type'] == null) {
      return response.change(headers: {
        ...response.headers,
        'Content-Type': 'application/json'
      });
    }
    return response;
  };
};

// --- Flutter Application Entry Point ---

void main() async {
  // Ensure Flutter widgets are initialized before starting the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Set up a ReceivePort to listen for messages from the backend isolate.
  final receivePort = ReceivePort();
  // Spawn the backend server in a new isolate.
  // This prevents the server from blocking the UI thread and provides a clean separation.
  await Isolate.spawn(_startBackendServer, receivePort.sendPort);

  // Listen for messages from the backend isolate.
  // This could be used to update UI with server status, but for this example, we just print.
  receivePort.listen((message) {
    debugPrint('Message from backend isolate: $message');
  });

  // Run the Flutter application.
  runApp(const FullStackApp());
}

// --- Flutter Application Widgets ---

/// The root widget of the Flutter application.
class FullStackApp extends StatelessWidget {
  const FullStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Full-Stack Flutter App',
      // Apply Material 3 design with a consistent color scheme.
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system, // Respect system light/dark mode preference.
      home: const HomeScreen(),
    );
  }
}

/// The main screen of the application, demonstrating interaction with the backend.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greeting = 'Tap to greet!';
  List<dynamic> _items = [];
  bool _isLoading = false;
  String? _error; // To display any errors from API calls.

  @override
  void initState() {
    super.initState();
    _fetchItems(); // Fetch initial items when the screen loads.
  }

  /// Fetches a greeting message from the local backend.
  Future<void> _fetchGreeting() async {
    setState(() {
      _isLoading = true;
      _error = null; // Clear previous errors.
    });
    try {
      final response = await http.get(Uri.parse('http://$_backendHost:$_backendPort/greet?name=FlutterDev'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _greeting = data['message'];
        });
      } else {
        setState(() {
          _error = 'Failed to fetch greeting: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching greeting: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fetches the list of items from the local backend.
  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _error = null; // Clear previous errors.
    });
    try {
      final response = await http.get(Uri.parse('http://$_backendHost:$_backendPort/items'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _items = data;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch items: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching items: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Sends a new item to the local backend using a POST request.
  Future<void> _addItem() async {
    setState(() {
      _isLoading = true;
      _error = null; // Clear previous errors.
    });
    try {
      final newItem = {
        'id': _items.length + 1, // Simple ID generation for demonstration.
        'name': 'New Item ${_items.length + 1}',
        'description': 'Dynamically added item from Flutter',
      };
      final response = await http.post(
        Uri.parse('http://$_backendHost:$_backendPort/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newItem),
      );

      if (response.statusCode == 201) {
        // If item created successfully (201 Created), refresh the list.
        await _fetchItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item added successfully!')),
          );
        }
      } else {
        setState(() {
          _error = 'Failed to add item: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error adding item: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Full-Stack Flutter App'),
        backgroundColor: colorScheme.primaryContainer,
        // Action button to refresh all data.
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : () {
              _fetchGreeting();
              _fetchItems();
            },
            tooltip: 'Refresh All Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator when fetching data.
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Section Card
                  Card(
                    margin: const EdgeInsets.only(bottom: 24.0),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _greeting,
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchGreeting,
                            icon: const Icon(Icons.waving_hand),
                            label: const Text('Greet Me'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Error Display Card
                  if (_error != null)
                    Card(
                      color: colorScheme.errorContainer,
                      margin: const EdgeInsets.only(bottom: 24.0),
                      elevation: 0, // No shadow for error card.
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Error: $_error',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Items Section Header with Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items from Backend',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Items List Display
                  Expanded(
                    child: _items.isEmpty
                        ? Center(
                            child: Text(
                              'No items found. Add some or check backend.',
                              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 1,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: colorScheme.secondaryContainer,
                                    child: Text(
                                      item['id'].toString(),
                                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSecondaryContainer),
                                    ),
                                  ),
                                  title: Text(item['name'] ?? 'No Name'),
                                  subtitle: Text(item['description'] ?? 'No Description'),
                                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurfaceVariant),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Tapped on: ${item['name']}')),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
