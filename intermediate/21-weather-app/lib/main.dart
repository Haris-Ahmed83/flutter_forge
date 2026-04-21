import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueAccent.shade700,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.blueAccent.shade700),
          headlineMedium: const TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          titleLarge: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600),
          bodyMedium: const TextStyle(fontSize: 16.0),
        ),
      ),
      home: const WeatherApp(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  // TODO: Replace with your actual OpenWeatherMap API key.
  // You can get one for free at https://openweathermap.org/api
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _baseUrl = 'api.openweathermap.org';

  Weather? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _cityController = TextEditingController(text: 'London'); // Default city
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Check if API key is set before making the initial fetch.
    if (_apiKey == 'YOUR_API_KEY_HERE' || _apiKey.isEmpty) {
      _errorMessage = 'API Key is not set. Please replace "YOUR_API_KEY_HERE" in main.dart.';
    } else {
      _fetchWeather(_cityController.text);
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  /// Fetches weather data from the OpenWeatherMap API for a given city.
  Future<void> _fetchWeather(String city) async {
    // Prevent API call if key is not set.
    if (_apiKey == 'YOUR_API_KEY_HERE' || _apiKey.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'API Key is not set. Please replace "YOUR_API_KEY_HERE" in main.dart.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _weatherData = null; // Clear previous data when fetching new weather
    });

    try {
      // Construct the URL for the OpenWeatherMap current weather API.
      final uri = Uri.https(_baseUrl, '/data/2.5/weather', {
        'q': city,
        'appid': _apiKey,
        'units': 'metric', // Request temperature in Celsius
      });

      final response = await http.get(uri); // Make the HTTP GET request.

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON.
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _weatherData = Weather.fromJson(data);
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // Handle 'city not found' error specifically.
        setState(() {
          _errorMessage = 'City not found. Please try another city.';
          _isLoading = false;
        });
      } else {
        // Handle other API errors.
        setState(() {
          _errorMessage = 'Failed to load weather data: ${response.statusCode}. Please try again.';
          _isLoading = false;
        });
      }
    } on http.ClientException catch (e) {
      // Handle network errors (e.g., no internet connection).
      setState(() {
        _errorMessage = 'Network error: ${e.message}. Please check your internet connection.';
        _isLoading = false;
      });
    } catch (e) {
      // Catch any other unexpected errors during parsing or API call.
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Enter City Name',
                  hintText: 'e.g., New York, Tokyo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _cityController.clear(),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city name.';
                  }
                  return null;
                },
                // Trigger weather fetch when user submits text field (e.g., presses enter on keyboard).
                onFieldSubmitted: (value) {
                  if (_formKey.currentState!.validate()) {
                    _fetchWeather(value);
                    FocusScope.of(context).unfocus(); // Dismiss keyboard after submission
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null // Disable button while loading
                  : () {
                      if (_formKey.currentState!.validate()) {
                        _fetchWeather(_cityController.text);
                        FocusScope.of(context).unfocus(); // Dismiss keyboard after submission
                      }
                    },
              icon: const Icon(Icons.search),
              label: const Text('Get Weather'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: _isLoading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading weather...', style: TextStyle(fontSize: 18)),
                        ],
                      )
                    : _errorMessage != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 60),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : _weatherData == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.wb_sunny_outlined,
                                    color: Colors.blueAccent.shade100,
                                    size: 80,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Enter a city to see the weather!',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.blueAccent.shade200,
                                    ),
                                  ),
                                ],
                              )
                            : _WeatherDisplay(weather: _weatherData!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget to display the fetched weather data in a user-friendly format.
class _WeatherDisplay extends StatelessWidget {
  final Weather weather;

  const _WeatherDisplay({required this.weather});

  @override
  Widget build(BuildContext context) {
    // Construct the URL for the weather icon provided by OpenWeatherMap.
    final String iconUrl = 'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          weather.cityName,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        // Display weather icon from the URL.
        Image.network(
          iconUrl,
          width: 100,
          height: 100,
          // Provide an error builder for when the image fails to load.
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, size: 100, color: Colors.grey),
        ),
        Text(
          '${weather.temperature.toStringAsFixed(1)}°C', // Display temperature with one decimal place.
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 8),
        Text(
          weather.description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.grey.shade700,
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}

/// Data model for weather information parsed from the OpenWeatherMap API response.
class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  /// Factory constructor to create a [Weather] object from a JSON map.
  /// It extracts relevant data from the nested JSON structure.
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] as String,
      temperature: (json['main']['temp'] as num).toDouble(), // Temperature from 'main' object
      description: (json['weather'][0]['description'] as String)
          .capitalize(), // Description from 'weather' array, first element, capitalized
      iconCode: json['weather'][0]['icon'] as String, // Icon code from 'weather' array
    );
  }
}

/// Extension to capitalize the first letter of a string.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
