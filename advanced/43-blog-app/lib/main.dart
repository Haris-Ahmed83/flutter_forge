import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert'; // For JSON encoding/decoding rich text content

// --- 1. Main Application Setup ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize Firebase.
  // Make sure you have added Firebase to your Flutter project
  // and run `flutterfire configure`.
  // Add your firebase_options.dart file or configure Firebase manually.
  // Example for firebase_options.dart (recommended):
  // import 'firebase_options.dart';
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  // Example for manual configuration (less secure/flexible for production):
  // await Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //     apiKey: "YOUR_API_KEY",
  //     appId: "YOUR_APP_ID",
  //     messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  //     projectId: "YOUR_PROJECT_ID",
  //     // authDomain: "YOUR_AUTH_DOMAIN", // Optional
  //     // storageBucket: "YOUR_STORAGE_BUCKET", // Optional
  //   ),
  // );
  await Firebase.initializeApp(); // Placeholder if firebase_options.dart is not set up yet

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Blog App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      home: const BlogListScreen(),
    );
  }
}

// --- 2. Data Model ---

/// Represents a single blog post.
class BlogPost {
  final String id;
  final String title;
  final String author;
  final String contentDelta; // Stored as a JSON string of Quill Delta operations
  final DateTime createdAt;
  final DateTime? updatedAt;

  BlogPost({
    required this.id,
    required this.title,
    required this.author,
    required this.contentDelta,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a BlogPost from a Firestore DocumentSnapshot.
  factory BlogPost.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BlogPost(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      author: data['author'] ?? 'Anonymous',
      // Default content if 'contentDelta' is missing or null
      contentDelta: data['contentDelta'] ?? jsonEncode([{'insert': 'No content.'}]),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts a BlogPost to a Map for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'contentDelta': contentDelta,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// --- 3. Firebase Service ---

/// Handles CRUD operations with Firestore for Blog Posts.
class FirestoreService {
  final CollectionReference _blogCollection =
      FirebaseFirestore.instance.collection('blogPosts');

  // C: Create a new blog post
  Future<void> addBlogPost(BlogPost post) async {
    await _blogCollection.add(post.toFirestore());
  }

  // R: Get all blog posts (as a stream for real-time updates)
  Stream<List<BlogPost>> getBlogPosts() {
    return _blogCollection
        .orderBy('createdAt', descending: true) // Order by creation date
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BlogPost.fromFirestore(doc))
            .toList());
  }

  // R: Get a single blog post by ID
  Future<BlogPost?> getBlogPostById(String id) async {
    DocumentSnapshot doc = await _blogCollection.doc(id).get();
    if (doc.exists) {
      return BlogPost.fromFirestore(doc);
    }
    return null;
  }

  // U: Update an existing blog post
  Future<void> updateBlogPost(BlogPost post) async {
    await _blogCollection.doc(post.id).update(post.toFirestore());
  }

  // D: Delete a blog post
  Future<void> deleteBlogPost(String id) async {
    await _blogCollection.doc(id).delete();
  }
}

// --- 4. Blog List Screen (Read All) ---

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blog'),
      ),
      body: StreamBuilder<List<BlogPost>>(
        stream: _firestoreService.getBlogPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No blog posts yet! Start writing.'));
          }

          final posts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlogDetailScreen(postId: post.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'By ${post.author} on ${post.createdAt.toLocal().toString().split(' ')[0]}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 12),
                        // Display a snippet of the rich text content
                        _buildContentSnippet(post.contentDelta),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BlogEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Extracts plain text from Quill Delta JSON for a snippet display.
  Widget _buildContentSnippet(String contentDelta) {
    try {
      final doc = Document.fromJson(jsonDecode(contentDelta));
      final text = doc.toPlainText().replaceAll('\n', ' ').trim();
      return Text(
        text.isNotEmpty ? text : 'No content preview.',
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    } catch (e) {
      // In case of malformed Delta JSON
      return Text(
        'Error loading content preview: $e',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}

// --- 5. Blog Detail Screen (Read Single) ---

class BlogDetailScreen extends StatefulWidget {
  final String postId;

  const BlogDetailScreen({super.key, required this.postId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<BlogPost?> _blogPostFuture;

  @override
  void initState() {
    super.initState();
    _blogPostFuture = _firestoreService.getBlogPostById(widget.postId);
  }

  /// Refreshes the blog post data.
  void _refreshPost() {
    setState(() {
      _blogPostFuture = _firestoreService.getBlogPostById(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final post = await _blogPostFuture;
              if (post != null) {
                // Navigate to edit screen with existing post data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlogEditScreen(post: post),
                  ),
                ).then((_) {
                  // Refresh post details after returning from edit screen
                  _refreshPost();
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<BlogPost?>(
        future: _blogPostFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Blog post not found.'));
          }

          final post = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By ${post.author} on ${post.createdAt.toLocal().toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                ),
                if (post.updatedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '(Last updated: ${post.updatedAt!.toLocal().toString().split(' ')[0]})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
                const Divider(height: 32),
                // Rich text display using QuillEditor in read-only mode
                QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                    controller: QuillController(
                      document: Document.fromJson(jsonDecode(post.contentDelta)),
                      selection: const TextSelection.collapsed(offset: 0),
                    ),
                    readOnly: true, // Set to true for display mode
                    padding: EdgeInsets.zero,
                    showCursor: false,
                    scrollable: false, // Ensure it expands to fit content
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a blog post.
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this blog post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              await _firestoreService.deleteBlogPost(widget.postId);
              if (mounted) {
                Navigator.of(context).pop(); // Go back to list screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Blog post deleted!')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// --- 6. Blog Edit/Create Screen (Create & Update) ---

class BlogEditScreen extends StatefulWidget {
  final BlogPost? post; // Null if creating a new post, otherwise editing an existing one

  const BlogEditScreen({super.key, this.post});

  @override
  State<BlogEditScreen> createState() => _BlogEditScreenState();
}

class _BlogEditScreenState extends State<BlogEditScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  late QuillController _quillController;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      // Editing existing post: pre-fill fields and Quill controller
      _titleController.text = widget.post!.title;
      _authorController.text = widget.post!.author;
      _quillController = QuillController(
        document: Document.fromJson(jsonDecode(widget.post!.contentDelta)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      // Creating new post: initialize with basic content
      _quillController = QuillController.basic();
      _authorController.text = 'Anonymous'; // Default author for new posts
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  /// Saves or updates the blog post to Firestore.
  Future<void> _saveBlogPost() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String title = _titleController.text.trim();
      final String author = _authorController.text.trim();
      final String contentDelta = jsonEncode(_quillController.document.toDelta().toJson());

      if (widget.post == null) {
        // Create new post
        final newPost = BlogPost(
          id: '', // Firestore will assign an ID automatically
          title: title,
          author: author,
          contentDelta: contentDelta,
          createdAt: DateTime.now(),
        );
        await _firestoreService.addBlogPost(newPost);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Blog post created successfully!')),
          );
        }
      } else {
        // Update existing post
        final updatedPost = BlogPost(
          id: widget.post!.id,
          title: title,
          author: author,
          contentDelta: contentDelta,
          createdAt: widget.post!.createdAt, // Preserve original creation date
          updatedAt: DateTime.now(), // Update modification date
        );
        await _firestoreService.updateBlogPost(updatedPost);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Blog post updated successfully!')),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop(); // Go back to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save post: $e')),
        );
      }
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
        title: Text(widget.post == null ? 'Create New Post' : 'Edit Post'),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveBlogPost,
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Author cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      QuillToolbar.basic(
                        configurations: QuillToolbarConfigurations(
                          controller: _quillController,
                          // Customize toolbar buttons for a cleaner look
                          showAlignmentButtons: false,
                          showDirection: false,
                          showFontFamily: false,
                          showFontSize: false,
                          showSearchButton: false,
                          showColorButton: false,
                          showBackgroundColorButton: false,
                          showIndent: false,
                          showLink: false,
                          showQuote: false,
                          showCodeBlock: false,
                          showInlineCode: false,
                          showListCheck: false,
                          showSuperscript: false,
                          showSubscript: false,
                          showStrikeThrough: false,
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),
                      Expanded(
                        child: QuillEditor.basic(
                          configurations: QuillEditorConfigurations(
                            controller: _quillController,
                            readOnly: false,
                            padding: const EdgeInsets.all(16.0),
                            scrollable: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
