import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const JobBoardApp());
}

// Job Model
class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final double salary;
  final String type; // e.g., 'Full-time', 'Part-time', 'Remote', 'Contract'
  final DateTime postedDate;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.salary,
    required this.type,
    required this.postedDate,
  });

  // Factory constructor to create a Job from a JSON map (simulated)
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      salary: (json['salary'] as num).toDouble(),
      type: json['type'] as String,
      postedDate: DateTime.parse(json['postedDate'] as String),
    );
  }

  // Helper to convert to JSON (for simulation, not strictly needed for this app)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'salary': salary,
      'type': type,
      'postedDate': postedDate.toIso8601String(),
    };
  }
}

// Simulated Job API Service
class JobApiService {
  // In a real app, this would be fetched from a backend.
  // Here, we generate a static list of jobs for demonstration.
  static final List<Job> _allJobs = _generateSampleJobs(50);
  static const int _itemsPerPage = 10; // Number of items per page

  // Simulates fetching jobs from an API with filtering and pagination
  Future<List<Job>> fetchJobs({
    int page = 1,
    String? query,
    String? type,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    // Apply filters
    List<Job> filteredJobs = _allJobs.where((job) {
      bool matchesQuery = true;
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        matchesQuery = job.title.toLowerCase().contains(lowerQuery) ||
            job.company.toLowerCase().contains(lowerQuery) ||
            job.location.toLowerCase().contains(lowerQuery);
      }

      bool matchesType = true;
      if (type != null && type.isNotEmpty && type != 'All') {
        matchesType = job.type == type;
      }

      return matchesQuery && matchesType;
    }).toList();

    // Sort jobs by posted date (newest first)
    filteredJobs.sort((a, b) => b.postedDate.compareTo(a.postedDate));

    // Apply pagination
    final int startIndex = (page - 1) * _itemsPerPage;
    final int endIndex = min(startIndex + _itemsPerPage, filteredJobs.length);

    if (startIndex >= filteredJobs.length) {
      return []; // No more data
    }

    return filteredJobs.sublist(startIndex, endIndex);
  }

  // Generates a list of sample jobs
  static List<Job> _generateSampleJobs(int count) {
    final List<Job> jobs = [];
    final Random random = Random();
    final List<String> titles = [
      'Software Engineer',
      'Flutter Developer',
      'Product Manager',
      'UI/UX Designer',
      'Data Scientist',
      'Marketing Specialist',
      'DevOps Engineer',
      'Frontend Developer',
      'Backend Developer',
      'Mobile Developer'
    ];
    final List<String> companies = [
      'Tech Solutions Inc.',
      'Innovate Corp.',
      'Global Dynamics',
      'Future Systems',
      'Creative Labs',
      'Digital Ventures',
      'NextGen Apps',
      'Cloud Innovations'
    ];
    final List<String> locations = [
      'New York, NY',
      'San Francisco, CA',
      'Remote',
      'London, UK',
      'Berlin, DE',
      'Toronto, ON',
      'Sydney, AUS'
    ];
    final List<String> types = ['Full-time', 'Part-time', 'Remote', 'Contract'];

    for (int i = 0; i < count; i++) {
      final String id = 'job_${i + 1}';
      final String title = titles[random.nextInt(titles.length)];
      final String company = companies[random.nextInt(companies.length)];
      final String location = locations[random.nextInt(locations.length)];
      final String type = types[random.nextInt(types.length)];
      final double salary = 50000 + random.nextDouble() * 150000;
      final DateTime postedDate = DateTime.now().subtract(Duration(days: random.nextInt(90)));
      final String description =
          'We are looking for a talented $title to join our team at $company. '
          'This role offers an exciting opportunity to work on cutting-edge projects '
          'and contribute to a dynamic environment. Responsibilities include '
          'developing and maintaining software, collaborating with cross-functional teams, '
          'and ensuring high-quality code. The ideal candidate will have strong '
          'problem-solving skills and a passion for technology.';

      jobs.add(Job(
        id: id,
        title: title,
        company: company,
        location: location,
        description: description,
        salary: salary,
        type: type,
        postedDate: postedDate,
      ));
    }
    return jobs;
  }
}

// Main Application Widget
class JobBoardApp extends StatelessWidget {
  const JobBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Board',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const JobListPage(),
    );
  }
}

// Job List Page Widget
class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  final JobApiService _apiService = JobApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Job> _jobs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _searchQuery;
  String? _selectedJobType = 'All'; // Default filter value
  Timer? _debounceTimer;

  // Available job types for the dropdown filter
  final List<String> _jobTypes = [
    'All',
    'Full-time',
    'Part-time',
    'Remote',
    'Contract'
  ];

  @override
  void initState() {
    super.initState();
    _fetchJobs(isInitialFetch: true); // Load initial jobs
    _scrollController.addListener(_scrollListener); // Listen for scroll events
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Fetches jobs from the API, handling pagination and filters
  Future<void> _fetchJobs({bool isInitialFetch = false, bool isRefresh = false}) async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches

    setState(() {
      _isLoading = true;
      if (isInitialFetch || isRefresh) {
        _jobs.clear(); // Clear existing jobs for initial load or refresh
        _currentPage = 1; // Reset page number
        _hasMore = true; // Assume there's more data
      }
    });

    try {
      final List<Job> newJobs = await _apiService.fetchJobs(
        page: _currentPage,
        query: _searchQuery,
        type: _selectedJobType,
      );

      setState(() {
        _jobs.addAll(newJobs); // Add new jobs to the list
        _currentPage++; // Increment page number for next fetch
        _hasMore = newJobs.isNotEmpty && newJobs.length == JobApiService._itemsPerPage; // Check if more data is available
      });
    } catch (e) {
      // In a real app, show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load jobs: $e')),
      );
      setState(() {
        _hasMore = false; // Stop trying to load more if an error occurs
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Listens to scroll events for infinite scrolling (pagination)
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        _hasMore &&
        !_isLoading) {
      _fetchJobs(); // Load more jobs when scrolled to the bottom
    }
  }

  // Handles search input changes with a debounce mechanism
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel(); // Cancel any existing debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != query) { // Only refetch if query actually changed
        setState(() {
          _searchQuery = query.trim().isEmpty ? null : query.trim();
        });
        _fetchJobs(isRefresh: true); // Refresh jobs with new search query
      }
    });
  }

  // Handles job type filter changes
  void _onJobTypeChanged(String? newValue) {
    if (_selectedJobType != newValue) {
      setState(() {
        _selectedJobType = newValue;
      });
      _fetchJobs(isRefresh: true); // Refresh jobs with new type filter
    }
  }

  // Clears all filters and refreshes the job list
  void _clearFilters() {
    _searchController.clear();
    _debounceTimer?.cancel();
    setState(() {
      _searchQuery = null;
      _selectedJobType = 'All';
    });
    _fetchJobs(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Board'),
        actions: [
          // Button to clear filters
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Filters'),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onPrimary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section: Search bar and Job Type dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by title, company, or location',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16.0),
                // Job Type Dropdown Filter
                DropdownButtonFormField<String>(
                  value: _selectedJobType,
                  decoration: InputDecoration(
                    labelText: 'Job Type',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  items: _jobTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: _onJobTypeChanged,
                ),
              ],
            ),
          ),
          // Job List Section
          Expanded(
            child: _jobs.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator()) // Show loader on initial fetch
                : _jobs.isEmpty
                    ? Center(
                        child: Text(
                          'No jobs found matching your criteria.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _jobs.length + (_hasMore ? 1 : 0), // Add 1 for loading indicator
                        itemBuilder: (context, index) {
                          if (index == _jobs.length) {
                            // Show loading indicator at the bottom when more data is expected
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final job = _jobs[index];
                          return JobCard(job: job);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// Widget to display a single job card
class JobCard extends StatelessWidget {
  final Job job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title
            Text(
              job.title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8.0),
            // Company and Location
            Row(
              children: [
                Icon(Icons.business, size: 18, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4.0),
                Text(
                  job.company,
                  style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 12.0),
                Icon(Icons.location_on, size: 18, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4.0),
                Text(
                  job.location,
                  style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Salary and Type
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                Chip(
                  label: Text('\$${job.salary.toStringAsFixed(0)}/year'),
                  avatar: Icon(Icons.monetization_on, color: colorScheme.onSecondaryContainer),
                  backgroundColor: colorScheme.secondaryContainer,
                  labelStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onSecondaryContainer),
                ),
                Chip(
                  label: Text(job.type),
                  avatar: Icon(Icons.work, color: colorScheme.onTertiaryContainer),
                  backgroundColor: colorScheme.tertiaryContainer,
                  labelStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onTertiaryContainer),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            // Description (truncated)
            Text(
              job.description,
              style: textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12.0),
            // Posted Date
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Posted: ${_formatDate(job.postedDate)}',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8.0),
            // Apply Button
            Align(
              alignment: Alignment.bottomRight,
              child: FilledButton.tonal(
                onPressed: () {
                  // In a real app, this would navigate to a job details page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Applying for ${job.title} at ${job.company}')),
                  );
                },
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to format date
  String _formatDate(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return '1 day ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
