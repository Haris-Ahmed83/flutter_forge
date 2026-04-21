import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON parsing
import 'package:intl/intl.dart'; // For date formatting

void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          // Use a dark theme for a modern look
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const NewsListPage(),
    );
  }
}

/// A data model for a single news article.
class NewsArticle {
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
  });

  /// Factory constructor to create a `NewsArticle` from a JSON map.
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] as String? ?? 'No Title', // Provide default for null safety
      description: json['description'] as String? ?? 'No description available.',
      imageUrl: json['imageUrl'] as String? ?? 'https://via.placeholder.com/150', // Placeholder for missing image
      source: json['source'] as String? ?? 'Unknown Source',
      publishedAt: DateTime.parse(json['publishedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

/// The main page displaying a list of news articles.
class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  List<NewsArticle> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Sample JSON data representing a list of news articles.
  // In a real app, this would come from an API call using the 'http' package.
  static const String _sampleJsonData = r'''
  [
    {
      "title": "Flutter 3.19 Released: What's New?",
      "description": "Flutter 3.19 brings new features, performance improvements, and bug fixes for a better development experience across all platforms.",
      "imageUrl": "https://images.unsplash.com/photo-1618395781308-4e12c1b2c3d5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8Zmx1dHRlcnx8fHx8fDE2NzkwNzQ4NDY&ixlib=rb-4.0.3&q=80&w=1080",
      "source": "Flutter Blog",
      "publishedAt": "2024-03-10T10:00:00Z"
    },
    {
      "title": "The Future of AI in Mobile Development",
      "description": "Artificial intelligence is rapidly transforming how mobile apps are built and how users interact with them, from personalized experiences to intelligent assistants.",
      "imageUrl": "https://images.unsplash.com/photo-1518779578619-383187a552f4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8YWl8fHx8fHwxNjc5MDc0ODQ3&ixlib=rb-4.0.3&q=80&w=1080",
      "source": "TechCrunch",
      "publishedAt": "2024-03-09T15:30:00Z"
    },
    {
      "title": "Sustainable Urban Planning Innovations",
      "description": "Cities around the world are adopting new strategies for eco-friendly and sustainable urban development, focusing on green infrastructure and public transport.",
      "imageUrl": "https://images.unsplash.com/photo-1596701072970-0726d11e5b1e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8c3VzdGFpbmFibGUlMjBjaXR5fHw&ixlib=rb-4.0.3&q=80&w=1080",
      "source": "Environmental News",
      "publishedAt": "2024-03-08T09:15:00Z"
    },
    {
      "title": "Breakthrough in Renewable Energy Storage",
      "description": "Scientists have announced a new method for storing renewable energy more efficiently and cost-effectively, promising a greener future.",
      "imageUrl": "https://images.unsplash.com/photo-1508620894056-5b3e2b3e2b3e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8cmVuZXdhYmxlJTIwZW5lcmd5fHw&ixlib=rb-4.0.3&q=80&w=1080",
      "source": "Science Daily",
      "publishedAt": "2024-03-07T11:45:00Z"
    },
    {
      "title": "Exploring the Depths of the Mariana Trench",
      "description": "A new expedition uncovers never-before-seen species and geological formations in the deepest part of the ocean, expanding our understanding of marine life.",
      "imageUrl": "https://images.unsplash.com/photo-1503756234508-e71c8926f06a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8b2NlYW4lMjBleHBsb3JhdGlvbnx8&ixlib=rb-4.0.3&q=80&w=1080",
      "source": "National Geographic",
      "publishedAt": "2024-03-06T14:00:00Z"
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  /// Simulates fetching news articles from an API and parses the JSON data.
  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Parse the JSON string into a list of NewsArticle objects.
      final List<dynamic> jsonList = jsonDecode(_sampleJsonData) as List<dynamic>;
      _articles = jsonList.map((json) => NewsArticle.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      _errorMessage = 'Failed to load articles: $e';
      debugPrint('Error fetching articles: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Headlines'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchArticles, // Disable refresh while loading
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchArticles,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _articles.isEmpty
                  ? const Center(
                      child: Text(
                        'No news articles found.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _articles.length,
                      itemBuilder: (context, index) {
                        final article = _articles[index];
                        return NewsArticleCard(article: article);
                      },
                    ),
    );
  }
}

/// A widget to display a single news article as a card in the list.
class NewsArticleCard extends StatelessWidget {
  final NewsArticle article;

  const NewsArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // Format the date for better readability.
    final String formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(article.publishedAt);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
      child: InkWell(
        onTap: () {
          // Navigate to the detail page when the card is tapped.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsArticleDetailPage(article: article),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article image with loading and error handling.
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  article.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: colorScheme.surfaceVariant,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: colorScheme.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: colorScheme.errorContainer,
                      child: Icon(
                        Icons.broken_image,
                        color: colorScheme.onErrorContainer,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              // Article title
              Text(
                article.title,
                style: textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              // Article description snippet
              Text(
                article.description,
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              // Source and published date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    article.source,
                    style: textTheme.labelLarge!.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: textTheme.labelSmall!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A detail page to display the full content of a news article.
class NewsArticleDetailPage extends StatelessWidget {
  final NewsArticle article;

  const NewsArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('MMMM dd, yyyy - HH:mm').format(article.publishedAt);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          style: textTheme.titleLarge!.copyWith(color: colorScheme.onPrimaryContainer),
        ),
        backgroundColor: colorScheme.primaryContainer,
        // Optional: Add a back button if not automatically provided
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                article.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: colorScheme.surfaceVariant,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: colorScheme.errorContainer,
                    child: Icon(
                      Icons.broken_image,
                      color: colorScheme.onErrorContainer,
                      size: 64,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            // Article title
            Text(
              article.title,
              style: textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8.0),
            // Source and published date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Source: ${article.source}',
                  style: textTheme.bodyLarge!.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formattedDate,
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            // Full article description
            Text(
              article.description,
              style: textTheme.bodyLarge!.copyWith(
                height: 1.5,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24.0),
            // A simple footer to demonstrate more content if needed
            Align(
              alignment: Alignment.center,
              child: Text(
                'End of Article',
                style: textTheme.labelMedium!.copyWith(color: colorScheme.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
