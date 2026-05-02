import 'package:flutter/material.dart';

// --- Data Models ---

/// Represents a user in the social media app.
class User {
  final String id;
  final String username;
  final String profileImageUrl;
  final String bio;
  int followers; // Mutable for follow/unfollow
  int following; // Mutable for follow/unfollow

  User({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.bio,
    this.followers = 0,
    this.following = 0,
  });

  User copyWith({
    String? id,
    String? username,
    String? profileImageUrl,
    String? bio,
    int? followers,
    int? following,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}

/// Represents a post made by a user.
class Post {
  final String id;
  final String userId;
  final String imageUrl;
  final String caption;
  final DateTime timestamp;
  int likes; // Mutable for like/unlike

  Post({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    required this.timestamp,
    this.likes = 0,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? caption,
    DateTime? timestamp,
    int? likes,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
    );
  }
}

// --- Simulated Backend Service ---

/// A singleton service to simulate backend operations for social media data.
/// Manages users, posts, follower relationships, and likes in memory.
class SocialService {
  static final SocialService _instance = SocialService._internal();

  factory SocialService() {
    return _instance;
  }

  SocialService._internal() {
    _initializeData();
  }

  // In-memory data stores
  final Map<String, User> _users = {};
  final Map<String, Post> _posts = {};
  // Tracks who follows whom: userId -> set of userIds they follow
  final Map<String, Set<String>> _following = {};
  // Tracks who likes which post: userId -> set of postIds they liked
  final Map<String, Set<String>> _likedPosts = {};

  // Default current user ID for demonstration purposes
  final String _currentUserId = 'user_1';

  /// Initializes sample data for users, posts, and relationships.
  void _initializeData() {
    // Sample Users
    final user1 = User(
      id: 'user_1',
      username: 'fluttermaster',
      profileImageUrl: 'https://picsum.photos/id/1005/200/200',
      bio: 'Building beautiful apps with Flutter!',
    );
    final user2 = User(
      id: 'user_2',
      username: 'codingninja',
      profileImageUrl: 'https://picsum.photos/id/1011/200/200',
      bio: 'Passionate about clean code and mobile development.',
    );
    final user3 = User(
      id: 'user_3',
      username: 'designguru',
      profileImageUrl: 'https://picsum.photos/id/1025/200/200',
      bio: 'UI/UX enthusiast, making apps delightful.',
    );
    final user4 = User(
      id: 'user_4',
      username: 'traveler_dev',
      profileImageUrl: 'https://picsum.photos/id/1015/200/200',
      bio: 'Exploring the world, one line of code at a time.',
    );

    _users[user1.id] = user1;
    _users[user2.id] = user2;
    _users[user3.id] = user3;
    _users[user4.id] = user4;

    // Sample Posts
    final post1 = Post(
      id: 'post_1',
      userId: user1.id,
      imageUrl: 'https://picsum.photos/id/237/600/400',
      caption: 'Enjoying the beautiful view! #nature #flutter',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    );
    final post2 = Post(
      id: 'post_2',
      userId: user2.id,
      imageUrl: 'https://picsum.photos/id/238/600/400',
      caption: 'My latest project in progress. So excited! #coding',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    );
    final post3 = Post(
      id: 'post_3',
      userId: user3.id,
      imageUrl: 'https://picsum.photos/id/239/600/400',
      caption: 'Designing new UI elements. What do you think? #design',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    );
    final post4 = Post(
      id: 'post_4',
      userId: user1.id,
      imageUrl: 'https://picsum.photos/id/240/600/400',
      caption: 'Another day, another line of code. #developerlife',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    );
    final post5 = Post(
      id: 'post_5',
      userId: user4.id,
      imageUrl: 'https://picsum.photos/id/241/600/400',
      caption: 'Exploring new places! #travel #adventure',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    );

    _posts[post1.id] = post1;
    _posts[post2.id] = post2;
    _posts[post3.id] = post3;
    _posts[post4.id] = post4;
    _posts[post5.id] = post5;

    // Sample Follow Relationships
    _following[_currentUserId] = {user2.id, user3.id}; // Current user follows user2 and user3
    _following[user2.id] = {_currentUserId, user3.id};
    _following[user3.id] = {_currentUserId, user2.id, user4.id};
    _following[user4.id] = {_currentUserId};

    // Update follower/following counts based on initial relationships
    _following.forEach((followerId, followedUsers) {
      _users[followerId]?.following = followedUsers.length;
      for (final followedId in followedUsers) {
        _users[followedId]?.followers = (_users[followedId]?.followers ?? 0) + 1;
      }
    });

    // Sample Likes
    _likedPosts[_currentUserId] = {post2.id, post3.id}; // Current user liked post2 and post3
    _likedPosts[user2.id] = {post1.id, post3.id, post4.id};
    _likedPosts[user3.id] = {post1.id, post2.id, post5.id};

    // Update post like counts based on initial likes
    _likedPosts.forEach((userId, likedPostIds) {
      for (final postId in likedPostIds) {
        _posts[postId]?.likes = (_posts[postId]?.likes ?? 0) + 1;
      }
    });
  }

  /// Simulates network delay.
  Future<void> _simulateDelay() => Future.delayed(const Duration(milliseconds: 700));

  /// Returns the current authenticated user.
  Future<User?> getCurrentUser() async {
    await _simulateDelay();
    return _users[_currentUserId];
  }

  /// Returns a user by their ID.
  Future<User?> getUserById(String userId) async {
    await _simulateDelay();
    return _users[userId];
  }

  /// Returns a list of posts for the current user's feed.
  /// Includes posts from followed users and the current user's own posts.
  Future<List<Post>> getFeedPostsForUser(String userId) async {
    await _simulateDelay();
    final Set<String> followedUserIds = _following[userId] ?? {};
    final Set<String> relevantUserIds = {userId, ...followedUserIds}; // Include own posts

    final List<Post> feedPosts = _posts.values
        .where((post) => relevantUserIds.contains(post.userId))
        .toList();

    // Sort by timestamp, newest first
    feedPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return feedPosts;
  }

  /// Returns a list of posts made by a specific user.
  Future<List<Post>> getProfilePostsForUser(String userId) async {
    await _simulateDelay();
    final List<Post> userPosts = _posts.values
        .where((post) => post.userId == userId)
        .toList();
    userPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return userPosts;
  }

  /// Returns a list of users that the current user might want to discover/follow.
  Future<List<User>> getDiscoverUsers(String currentUserId) async {
    await _simulateDelay();
    final Set<String> followedUserIds = _following[currentUserId] ?? {};
    final List<User> discoverUsers = _users.values
        .where((user) => user.id != currentUserId && !followedUserIds.contains(user.id))
        .toList();
    return discoverUsers;
  }

  /// Checks if the current user is following a target user.
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    await _simulateDelay();
    return (_following[currentUserId] ?? {}).contains(targetUserId);
  }

  /// Toggles the follow status for a target user by the current user.
  Future<bool> toggleFollow(String currentUserId, String targetUserId) async {
    await _simulateDelay();
    final bool isCurrentlyFollowing = await isFollowing(currentUserId, targetUserId);

    if (isCurrentlyFollowing) {
      // Unfollow
      _following[currentUserId]?.remove(targetUserId);
      _users[currentUserId]?.following = (_users[currentUserId]?.following ?? 1) - 1;
      _users[targetUserId]?.followers = (_users[targetUserId]?.followers ?? 1) - 1;
      return false; // Now unfollowed
    } else {
      // Follow
      _following.putIfAbsent(currentUserId, () => {}).add(targetUserId);
      _users[currentUserId]?.following = (_users[currentUserId]?.following ?? 0) + 1;
      _users[targetUserId]?.followers = (_users[targetUserId]?.followers ?? 0) + 1;
      return true; // Now followed
    }
  }

  /// Checks if the current user has liked a specific post.
  Future<bool> hasLikedPost(String currentUserId, String postId) async {
    await _simulateDelay();
    return (_likedPosts[currentUserId] ?? {}).contains(postId);
  }

  /// Toggles the like status for a post by the current user.
  Future<bool> toggleLikePost(String currentUserId, String postId) async {
    await _simulateDelay();
    final bool currentlyLiked = await hasLikedPost(currentUserId, postId);
    final Post? post = _posts[postId];

    if (post == null) return false; // Post not found

    if (currentlyLiked) {
      // Unlike
      _likedPosts[currentUserId]?.remove(postId);
      post.likes = (post.likes == 0) ? 0 : post.likes - 1;
      return false; // Now unliked
    } else {
      // Like
      _likedPosts.putIfAbsent(currentUserId, () => {}).add(postId);
      post.likes = post.likes + 1;
      return true; // Now liked
    }
  }
}

// --- Main App Widget ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// --- Home Page with Bottom Navigation Bar ---

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final SocialService _socialService = SocialService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  /// Loads the current user data from the service.
  Future<void> _loadCurrentUser() async {
    setState(() {
      _isLoading = true;
    });
    _currentUser = await _socialService.getCurrentUser();
    setState(() {
      _isLoading = false;
    });
  }

  /// Handles bottom navigation bar item taps.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Could not load current user.')),
      );
    }

    final List<Widget> widgetOptions = <Widget>[
      FeedScreen(currentUserId: _currentUser!.id),
      DiscoverScreen(currentUserId: _currentUser!.id),
      ProfileScreen(userId: _currentUser!.id), // Current user's profile
    ];

    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- Feed Screen ---

class FeedScreen extends StatefulWidget {
  final String currentUserId;

  const FeedScreen({super.key, required this.currentUserId});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final SocialService _socialService = SocialService();
  List<Post> _feedPosts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  /// Loads the feed posts for the current user.
  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final posts = await _socialService.getFeedPostsForUser(widget.currentUserId);
      setState(() {
        _feedPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load feed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeed,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _feedPosts.isEmpty
                  ? Center(
                      child: Text(
                        'No posts yet. Follow more users!',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _feedPosts.length,
                      itemBuilder: (context, index) {
                        final post = _feedPosts[index];
                        return PostCard(
                          post: post,
                          currentUserId: widget.currentUserId,
                          onLikeToggle: _loadFeed, // Refresh feed on like toggle
                          onUserTap: (userId) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(userId: userId),
                              ),
                            ).then((_) => _loadFeed()); // Refresh feed if profile was of followed user
                          },
                        );
                      },
                    ),
    );
  }
}

// --- Discover Screen ---

class DiscoverScreen extends StatefulWidget {
  final String currentUserId;

  const DiscoverScreen({super.key, required this.currentUserId});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final SocialService _socialService = SocialService();
  List<User> _discoverUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDiscoverUsers();
  }

  /// Loads users for the discover section.
  Future<void> _loadDiscoverUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final users = await _socialService.getDiscoverUsers(widget.currentUserId);
      setState(() {
        _discoverUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load discover users: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiscoverUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _discoverUsers.isEmpty
                  ? Center(
                      child: Text(
                        'No new users to discover!',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _discoverUsers.length,
                      itemBuilder: (context, index) {
                        final user = _discoverUsers[index];
                        return UserListItem(
                          user: user,
                          currentUserId: widget.currentUserId,
                          onUserTap: (userId) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(userId: userId),
                              ),
                            ).then((_) => _loadDiscoverUsers()); // Refresh discover list on return
                          },
                          onFollowToggle: _loadDiscoverUsers, // Refresh list on follow/unfollow
                        );
                      },
                    ),
    );
  }
}

// --- Profile Screen ---

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SocialService _socialService = SocialService();
  User? _profileUser;
  List<Post> _userPosts = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFollowing = false; // State for the follow button

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadProfileData();
    }
  }

  /// Loads user profile and their posts.
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final currentUser = await _socialService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Current user not found.');
      }

      final user = await _socialService.getUserById(widget.userId);
      if (user == null) {
        throw Exception('Profile user not found.');
      }

      final posts = await _socialService.getProfilePostsForUser(widget.userId);
      final isFollowingStatus = await _socialService.isFollowing(currentUser.id, widget.userId);

      setState(() {
        _profileUser = user;
        _userPosts = posts;
        _isFollowing = isFollowingStatus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  /// Toggles the follow status for the profile user.
  Future<void> _toggleFollow() async {
    if (_profileUser == null) return;

    final currentUser = await _socialService.getCurrentUser();
    if (currentUser == null) return; // Should not happen if app starts correctly

    setState(() {
      _isLoading = true; // Show loading while toggling
    });

    try {
      final newFollowStatus = await _socialService.toggleFollow(currentUser.id, _profileUser!.id);
      setState(() {
        _isFollowing = newFollowStatus;
        // Manually update counts for immediate UI feedback before full reload
        if (newFollowStatus) {
          _profileUser = _profileUser!.copyWith(followers: _profileUser!.followers + 1);
        } else {
          _profileUser = _profileUser!.copyWith(followers: _profileUser!.followers - 1);
        }
        _isLoading = false;
      });
      // A full reload ensures consistency, especially if other counts are affected
      _loadProfileData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to toggle follow: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_profileUser?.username ?? 'Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _profileUser == null
                  ? const Center(child: Text('User profile not found.'))
                  : RefreshIndicator(
                      onRefresh: _loadProfileData,
                      child: ListView(
                        children: [
                          _UserProfileHeader(
                            user: _profileUser!,
                            isCurrentUser: widget.userId == SocialService()._currentUserId,
                            isFollowing: _isFollowing,
                            onFollowToggle: _toggleFollow,
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Posts',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          _userPosts.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: Text('No posts yet.')),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 4.0,
                                  ),
                                  itemCount: _userPosts.length,
                                  itemBuilder: (context, index) {
                                    final post = _userPosts[index];
                                    return GestureDetector(
                                      onTap: () {
                                        // Navigate to full post view or show dialog
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(post.caption),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.network(post.imageUrl, fit: BoxFit.cover),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Text('${post.likes} likes'),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        post.imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
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

// --- Reusable Widgets ---

/// Displays a single post item in the feed.
class PostCard extends StatefulWidget {
  final Post post;
  final String currentUserId;
  final VoidCallback onLikeToggle;
  final Function(String userId) onUserTap;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLikeToggle,
    required this.onUserTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final SocialService _socialService = SocialService();
  User? _postAuthor;
  bool _hasLiked = false;
  bool _isLiking = false; // Prevents multiple rapid taps

  @override
  void initState() {
    super.initState();
    _loadPostAuthorAndLikeStatus();
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id || oldWidget.currentUserId != widget.currentUserId) {
      _loadPostAuthorAndLikeStatus();
    }
  }

  /// Loads the author of the post and checks if the current user has liked it.
  Future<void> _loadPostAuthorAndLikeStatus() async {
    final author = await _socialService.getUserById(widget.post.userId);
    final liked = await _socialService.hasLikedPost(widget.currentUserId, widget.post.id);
    if (mounted) {
      setState(() {
        _postAuthor = author;
        _hasLiked = liked;
      });
    }
  }

  /// Toggles the like status for the post.
  Future<void> _toggleLike() async {
    if (_isLiking) return; // Prevent multiple likes while one is in progress

    setState(() {
      _isLiking = true;
    });

    try {
      final newLikedStatus = await _socialService.toggleLikePost(widget.currentUserId, widget.post.id);
      if (mounted) {
        setState(() {
          _hasLiked = newLikedStatus;
          // Update local post object's likes count for immediate UI feedback
          if (newLikedStatus) {
            widget.post.likes++;
          } else {
            widget.post.likes--;
          }
        });
      }
      widget.onLikeToggle(); // Notify parent to potentially refresh data
    } catch (e) {
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle like: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0), // Remove horizontal margin
      elevation: 0, // No elevation for a cleaner look
      shape: const RoundedRectangleBorder(), // No rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header (User Info)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () => widget.onUserTap(widget.post.userId),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(_postAuthor?.profileImageUrl ?? 'https://via.placeholder.com/150'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _postAuthor?.username ?? 'Unknown User',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // Post Image
          Image.network(
            widget.post.imageUrl,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 300,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 300,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          // Actions (Like, Comment - simulated)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _hasLiked ? Icons.favorite : Icons.favorite_border,
                    color: _hasLiked ? Colors.red : null,
                  ),
                  onPressed: _isLiking ? null : _toggleLike, // Disable while liking
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comment feature not implemented')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share feature not implemented')),
                    );
                  },
                ),
                const Spacer(),
                Text(
                  '${widget.post.likes} likes',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '${_postAuthor?.username ?? 'Unknown'}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: widget.post.caption),
                ],
              ),
            ),
          ),
          // Timestamp
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
            child: Text(
              _formatTimestamp(widget.post.timestamp),
              style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const Divider(height: 1), // Separator between posts
        ],
      ),
    );
  }

  /// Formats a DateTime object into a human-readable string.
  String _formatTimestamp(DateTime timestamp) {
    final Duration diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Displays a user's profile header with picture, counts, and follow button.
class _UserProfileHeader extends StatelessWidget {
  final User user;
  final bool isCurrentUser;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const _UserProfileHeader({
    required this.user,
    required this.isCurrentUser,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.profileImageUrl),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(context, user.followers, 'Followers'),
                    _buildStatColumn(context, user.following, 'Following'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              user.username,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              user.bio,
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          if (!isCurrentUser)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFollowToggle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? Theme.of(context).colorScheme.surfaceVariant
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor:
                      isFollowing ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isFollowing ? 'Unfollow' : 'Follow',
                  style: textTheme.titleMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Helper to build a column for follower/following counts.
  Column _buildStatColumn(BuildContext context, int count, String label) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          count.toString(),
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

/// Displays a user in a list, typically for discover or search results.
class UserListItem extends StatefulWidget {
  final User user;
  final String currentUserId;
  final Function(String userId) onUserTap;
  final VoidCallback onFollowToggle; // Callback to refresh parent list

  const UserListItem({
    super.key,
    required this.user,
    required this.currentUserId,
    required this.onUserTap,
    required this.onFollowToggle,
  });

  @override
  State<UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  final SocialService _socialService = SocialService();
  bool _isFollowing = false;
  bool _isLoadingFollow = false; // To prevent multiple taps while follow/unfollow is in progress

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  @override
  void didUpdateWidget(covariant UserListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id || oldWidget.currentUserId != widget.currentUserId) {
      _checkFollowingStatus();
    }
  }

  /// Checks if the current user is following this user.
  Future<void> _checkFollowingStatus() async {
    final bool status = await _socialService.isFollowing(widget.currentUserId, widget.user.id);
    if (mounted) {
      setState(() {
        _isFollowing = status;
      });
    }
  }

  /// Toggles the follow status for this user.
  Future<void> _toggleFollow() async {
    if (_isLoadingFollow) return; // Prevent multiple actions

    setState(() {
      _isLoadingFollow = true;
    });

    try {
      final newStatus = await _socialService.toggleFollow(widget.currentUserId, widget.user.id);
      if (mounted) {
        setState(() {
          _isFollowing = newStatus;
        });
      }
      widget.onFollowToggle(); // Notify parent to refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle follow: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(widget.user.profileImageUrl),
      ),
      title: Text(
        widget.user.username,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        widget.user.bio,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: widget.user.id == widget.currentUserId
          ? null // No follow button for self
          : ElevatedButton(
              onPressed: _isLoadingFollow ? null : _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.primary,
                foregroundColor:
                    _isFollowing ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(90, 36), // Fixed minimum size for consistency
              ),
              child: _isLoadingFollow
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isFollowing ? 'Following' : 'Follow'),
            ),
      onTap: () => widget.onUserTap(widget.user.id),
    );
  }
}
