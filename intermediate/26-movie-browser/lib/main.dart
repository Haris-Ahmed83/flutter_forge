import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting utility

// TODO: Replace with your actual TMDB API key.
// You can get one from https://www.themoviedb.org/documentation/api
// Register an account, go to settings -> API -> Request an API Key.
const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE';

// Base URLs for TMDB API and images.
const String tmdbBaseUrl = 'api.themoviedb.org';
const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500'; // For movie posters (w500 is a good size for lists/details)

void main() => runApp(const MovieBrowserApp());

/// A model class representing a single movie with data from TMDB.
class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath; // Path to the movie poster image, can be null.
  final DateTime? releaseDate; // Release date of the movie, can be null.
  final double voteAverage; // Average vote/rating of the movie.

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.releaseDate,
    required this.voteAverage,
  });

  /// Factory constructor to create a [Movie] object from a JSON map.
  factory Movie.fromJson(Map<String, dynamic> json) {
    // Attempt to parse the release date string into a DateTime object.
    // Handles cases where 'release_date' might be null, empty, or malformed.
    DateTime? parsedReleaseDate;
    if (json['release_date'] != null &&
        json['release_date'] is String &&
        (json['release_date'] as String).isNotEmpty) {
      try {
        parsedReleaseDate = DateTime.parse(json['release_date']);
      } catch (e) {
        // Log or handle parsing error if necessary, keeping parsedReleaseDate null.
      }
    }

    return Movie(
      id: json['id'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String,
      posterPath: json['poster_path'] as String?,
      releaseDate: parsedReleaseDate,
      // TMDB API returns vote_average as a number (int or double), convert to double.
      voteAverage: (json['vote_average'] as num).toDouble(),
    );
  }
}

/// Fetches a list of popular movies from the TMDB API.
/// Throws an [Exception] if the API key is missing or if the network request fails.
Future<List<Movie>> fetchPopularMovies() async {
  // Ensure the API key is set before making a request.
  if (tmdbApiKey == 'YOUR_TMDB_API_KEY_HERE' || tmdbApiKey.isEmpty) {
    throw Exception('TMDB API Key is not set. Please replace \'YOUR_TMDB_API_KEY_HERE\' in main.dart.');
  }

  // Construct the URI for the popular movies endpoint.
  final uri = Uri.https(tmdbBaseUrl, '/3/movie/popular', {
    'api_key': tmdbApiKey,
    'language': 'en-US', // Request movies in English.
    'page': '1', // Fetch the first page of popular movies.
  });

  try {
    final response = await http.get(uri); // Make the HTTP GET request.

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results']; // Extract the list of movie results.

      // Map each JSON movie object to a Movie model object.
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load movies. Status code: ${response.statusCode}. Body: ${response.body}');
    }
  } catch (e) {
    // Catch any network-related errors (e.g., no internet connection).
    throw Exception('Failed to connect to TMDB API: $e');
  }
}

/// The root widget of the Movie Browser application.
class MovieBrowserApp extends StatelessWidget {
  const MovieBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Browser',
      debugShowCheckedModeBanner: false, // Hide the debug banner.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Define primary color scheme.
        useMaterial3: true, // Enable Material 3 design.
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        // Define custom text themes for consistent typography.
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
      home: const MovieListScreen(), // Set the initial screen to MovieListScreen.
    );
  }
}

/// A screen that displays a list of popular movies using a [FutureBuilder].
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  // A Future that will hold the list of movies. It's initialized in initState.
  late Future<List<Movie>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = fetchPopularMovies(); // Start fetching movies when the screen initializes.
  }

  /// Refreshes the movie list by re-fetching data from the API.
  /// This method is called by the [RefreshIndicator].
  Future<void> _refreshMovies() async {
    setState(() {
      _moviesFuture = fetchPopularMovies(); // Update the future to trigger a re-fetch.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Movies'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMovies, // Enable pull-to-refresh functionality.
        child: FutureBuilder<List<Movie>>(
          future: _moviesFuture, // The Future to monitor for changes.
          builder: (context, snapshot) {
            // Display a loading indicator while the data is being fetched.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Display an error message if the future completes with an error.
            else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load movies: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refreshMovies, // Allow the user to retry fetching.
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }
            // Display the movie list if the future completes successfully with data.
            else if (snapshot.hasData) {
              final movies = snapshot.data!;
              if (movies.isEmpty) {
                return const Center(
                  child: Text('No popular movies found.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return MovieListItem(movie: movie); // Display each movie using MovieListItem.
                },
              );
            }
            // Fallback for other states (e.g., ConnectionState.none, which is rare for an initialized future).
            else {
              return const Center(child: Text('No data available.'));
            }
          },
        ),
      ),
    );
  }
}

/// A widget representing a single movie item in the list, displayed as a card.
class MovieListItem extends StatelessWidget {
  final Movie movie;

  const MovieListItem({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    // Format the release date for display, or show 'Unknown' if not available.
    final String releaseDate = movie.releaseDate != null
        ? DateFormat.yMMMd().format(movie.releaseDate!)
        : 'Unknown Release Date';

    // Construct the full URL for the movie poster, or use a placeholder if posterPath is null.
    final String imageUrl = movie.posterPath != null
        ? '$tmdbImageBaseUrl${movie.posterPath}'
        : 'https://via.placeholder.com/500x750?text=No+Image'; // Generic placeholder for missing image

    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to the movie detail screen when the card is tapped.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster with a Hero animation tag for smooth transitions.
              Hero(
                tag: 'movie-poster-${movie.id}', // Unique tag for Hero animation.
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                    // Display a fallback icon if the image fails to load.
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 150,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Movie details (title, release date, rating, and a snippet of the overview).
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // Truncate long titles.
                    ),
                    const SizedBox(height: 4),
                    Text(
                      releaseDate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star_rate_rounded, color: Colors.amber[700], size: 18),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1), // Display rating with one decimal place.
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis, // Truncate long overviews.
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A screen that displays detailed information about a selected movie.
class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    // Format the release date for display.
    final String releaseDate = movie.releaseDate != null
        ? DateFormat.yMMMd().format(movie.releaseDate!)
        : 'Unknown Release Date';

    // Construct the full URL for the movie poster, or use a placeholder.
    final String imageUrl = movie.posterPath != null
        ? '$tmdbImageBaseUrl${movie.posterPath}'
        : 'https://via.placeholder.com/500x750?text=No+Image';

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster with Hero animation tag (must match the tag in MovieListItem).
            Center(
              child: Hero(
                tag: 'movie-poster-${movie.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    height: 300,
                    fit: BoxFit.cover,
                    // Fallback for image loading errors.
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      width: 200, // Approximate width for aspect ratio
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 60),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              movie.title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Text(
                  releaseDate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(width: 20),
                Icon(Icons.star_rate_rounded, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${movie.voteAverage.toStringAsFixed(1)} / 10', // Display rating out of 10.
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              movie.overview.isNotEmpty ? movie.overview : 'No overview available.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
