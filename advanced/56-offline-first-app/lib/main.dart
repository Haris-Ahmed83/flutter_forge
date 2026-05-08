import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'dart:async'; // For Timer and Future.delayed
import 'dart:math'; // For random delays in simulated backend

// --- 1. Data Model: Task ---
// This class represents a single ToDo task.
// It includes fields for its unique ID, title, completion status,
// last modification timestamp (for sync), a dirty flag (for offline changes),
// and a soft-delete flag.
class Task {
  String id;
  String title;
  bool isCompleted;
  DateTime lastModified;
  bool isDirty; // True if local changes haven't been synced to the remote
  bool isDeleted; // True if task is logically deleted, awaiting remote sync

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.lastModified,
    this.isDirty = false,
    this.isDeleted = false,
  });

  // Factory constructor to create a Task from a JSON-like map (e.g., from remote API)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      lastModified: DateTime.parse(json['lastModified'] as String),
      isDirty: json['isDirty'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  // Method to convert a Task instance to a JSON-like map (e.g., for remote API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'lastModified': lastModified.toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
    };
  }

  // Helper method to create a new Task instance with updated fields.
  // Useful for immutability and updating specific properties.
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? lastModified,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      lastModified: lastModified ?? this.lastModified,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted, lastModified: $lastModified, isDirty: $isDirty, isDeleted: $isDeleted)';
  }
}

// --- 2. Hive Adapter for Task (Manual Implementation) ---
// This adapter allows Hive to efficiently store and retrieve `Task` objects.
// In a multi-file project, this would typically be auto-generated using `build_runner`
// with `@HiveType` and `@HiveField` annotations. For a single-file constraint,
// we implement it manually.
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0; // Unique identifier for this adapter within Hive

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      lastModified: fields[3] as DateTime,
      isDirty: fields[4] as bool,
      isDeleted: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(6) // Number of fields to write
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.lastModified)
      ..writeByte(4)
      ..write(obj.isDirty)
      ..writeByte(5)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// --- 3. Simulated Backend Service ---
// This class simulates a remote REST API for tasks.
// It uses an in-memory Map to store "server-side" data and `Future.delayed`
// to mimic network latency, making the sync logic more realistic.
class RemoteApiService {
  // In-memory "database" on the simulated server
  static final Map<String, Task> _remoteTasksDb = {};
  static final Random _random = Random();

  // Initializes the simulated backend with some sample data if it's empty.
  static void initializeRemoteData() {
    if (_remoteTasksDb.isEmpty) {
      final uuid = Uuid();
      _remoteTasksDb[uuid.v4()] = Task(
        id: uuid.v4(),
        title: 'Buy groceries (Remote)',
        isCompleted: false,
        lastModified: DateTime.now().subtract(const Duration(days: 2)),
      );
      _remoteTasksDb[uuid.v4()] = Task(
        id: uuid.v4(),
        title: 'Plan weekend trip (Remote)',
        isCompleted: true,
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
      );
      _remoteTasksDb[uuid.v4()] = Task(
        id: uuid.v4(),
        title: 'Read Flutter documentation (Remote)',
        isCompleted: false,
        lastModified: DateTime.now().subtract(const Duration(hours: 12)),
      );
    }
  }

  // Simulates fetching all active tasks from the remote server.
  Future<List<Task>> fetchAllTasks() async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000))); // Simulate network delay
    // Only return tasks not marked as deleted in the remote DB
    return _remoteTasksDb.values.where((task) => !task.isDeleted).toList();
  }

  // Simulates pushing a task (creation or update) to the remote server.
  // The server updates the `lastModified` timestamp and clears the `isDirty` flag.
  Future<Task> pushTask(Task task) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700))); // Simulate network delay
    final updatedTask = task.copyWith(
      lastModified: DateTime.now(), // Server sets the true last modified time
      isDirty: false, // Server confirms it's no longer dirty
      isDeleted: task.isDeleted, // Maintain delete status
    );
    _remoteTasksDb[updatedTask.id] = updatedTask;
    return updatedTask;
  }

  // Simulates deleting a task from the remote server.
  Future<void> deleteTask(String taskId) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(500))); // Simulate network delay
    _remoteTasksDb.remove(taskId);
  }
}

// --- 4. Main Application Entry Point ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register the custom TaskAdapter.
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  // Open the Hive box where Task objects will be stored.
  await Hive.openBox<Task>('tasksBox');

  // Initialize the simulated remote backend with some data.
  RemoteApiService.initializeRemoteData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline-First ToDo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
      ),
      home: const TaskListPage(),
    );
  }
}

// --- 5. Task List Page (Main UI) ---
// This StatefulWidget manages the display and synchronization of tasks.
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Box<Task> _tasksBox; // Hive box for local task storage
  final RemoteApiService _remoteApiService = RemoteApiService(); // Simulated backend service
  bool _isSyncing = false; // Flag to indicate if a sync operation is in progress
  String _syncStatus = 'Idle'; // User-facing sync status message
  Timer? _syncTimer; // Timer for periodic background synchronization

  @override
  void initState() {
    super.initState();
    _tasksBox = Hive.box<Task>('tasksBox'); // Get the opened Hive box
    _loadInitialData(); // Load data and potentially trigger first sync
    _startPeriodicSync(); // Start background sync timer
  }

  @override
  void dispose() {
    _syncTimer?.cancel(); // Cancel the periodic timer to prevent memory leaks
    super.dispose();
  }

  // Loads initial data into the UI. If the local box is empty, it triggers an
  // initial sync to pull data from the remote.
  Future<void> _loadInitialData() async {
    if (_tasksBox.isEmpty) {
      await _syncData(initialSync: true);
    }
  }

  // Starts a periodic timer to automatically synchronize data with the remote.
  void _startPeriodicSync() {
    // Sync every 30 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _syncData();
    });
  }

  // --- Core Synchronization Logic ---
  // This method orchestrates the two-way synchronization between local Hive data
  // and the simulated remote backend.
  Future<void> _syncData({bool initialSync = false}) async {
    if (_isSyncing) return; // Prevent concurrent sync operations

    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing...';
    });

    try {
      // 1. Fetch current state from remote and local
      final List<Task> remoteTasks = await _remoteApiService.fetchAllTasks();
      final List<Task> localTasks = _tasksBox.values.toList();

      // Create maps for efficient lookup by ID
      final Map<String, Task> remoteTaskMap = {for (var t in remoteTasks) t.id: t};
      final Map<String, Task> localTaskMap = {for (var t in localTasks) t.id: t};

      final List<Future<void>> syncOperations = [];

      // 2. Process local changes: Push dirty tasks (new, updated, deleted) to remote
      for (final localTask in localTasks) {
        if (localTask.isDirty) {
          syncOperations.add(() async {
            try {
              if (localTask.isDeleted) {
                // Task is marked for deletion locally: delete it remotely
                await _remoteApiService.deleteTask(localTask.id);
                await _tasksBox.delete(localTask.id); // Remove from local after remote success
              } else {
                // Task is new or updated locally: push it to remote
                final syncedTask = await _remoteApiService.pushTask(localTask);
                // Update local task with remote's timestamp and clear dirty flag
                await _tasksBox.put(localTask.id, syncedTask.copyWith(isDirty: false));
              }
            } catch (e) {
              debugPrint('Error pushing task ${localTask.id}: $e');
              // Task remains dirty, will be retried on next sync
            }
          }());
        }
      }
      await Future.wait(syncOperations); // Wait for all pushes to complete
      syncOperations.clear();

      // Re-fetch local tasks in case they were modified during the push phase
      final List<Task> updatedLocalTasks = _tasksBox.values.toList();
      final Map<String, Task> updatedLocalTaskMap = {for (var t in updatedLocalTasks) t.id: t};

      // 3. Process remote changes: Pull new/updated tasks from remote to local
      for (final remoteTask in remoteTasks) {
        final localTask = updatedLocalTaskMap[remoteTask.id];

        if (localTask == null) {
          // Task exists remotely but not locally: pull it
          syncOperations.add(_tasksBox.put(remoteTask.id, remoteTask));
        } else {
          // Task exists both locally and remotely. Conflict resolution:
          // If local is dirty, local changes take precedence (already handled in step 2 or will be).
          // If local is *not* dirty and remote is newer, remote wins (pull remote).
          if (!localTask.isDirty && remoteTask.lastModified.isAfter(localTask.lastModified)) {
            syncOperations.add(_tasksBox.put(remoteTask.id, remoteTask));
          }
        }
      }

      // 4. Handle tasks deleted remotely: Remove from local if not dirty
      for (final localTask in updatedLocalTasks) {
        if (!localTask.isDirty && !remoteTaskMap.containsKey(localTask.id)) {
          // Task exists locally but not remotely, and local is not dirty: remote deletion wins
          syncOperations.add(_tasksBox.delete(localTask.id));
        }
      }

      await Future.wait(syncOperations); // Wait for all pulls/deletions to complete

      setState(() {
        _syncStatus = 'Last synced: ${DateTime.now().toIso8601String().substring(11, 19)}';
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Sync failed: ${e.toString().split(':')[0]}'; // Show concise error
      });
      debugPrint('Sync error: $e');
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  // --- Local CRUD Operations with Dirty Flagging ---

  // Adds a new task locally, marks it as dirty, and triggers a sync.
  Future<void> _addTask(String title) async {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      lastModified: DateTime.now(),
      isDirty: true, // Mark as dirty immediately for sync
    );
    await _tasksBox.put(newTask.id, newTask);
    setState(() {}); // Rebuild UI to show new task
    _syncData(); // Trigger sync after local change
  }

  // Toggles the completion status of a task, marks it dirty, and triggers a sync.
  Future<void> _toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      lastModified: DateTime.now(),
      isDirty: true, // Mark as dirty for sync
    );
    await _tasksBox.put(updatedTask.id, updatedTask);
    setState(() {}); // Rebuild UI
    _syncData(); // Trigger sync
  }

  // Marks a task for soft deletion locally, marks it dirty, and triggers a sync.
  // The actual removal from Hive happens after successful remote deletion during sync.
  Future<void> _deleteTask(Task task) async {
    final deletedTask = task.copyWith(
      isDeleted: true,
      lastModified: DateTime.now(),
      isDirty: true, // Mark as dirty to push deletion to remote
    );
    await _tasksBox.put(deletedTask.id, deletedTask);
    setState(() {}); // Rebuild UI
    _syncData(); // Trigger sync
  }

  // --- UI Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline-First Tasks'),
        actions: [
          // Sync button with loading indicator
          IconButton(
            icon: _isSyncing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                    ),
                  )
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _syncData, // Disable button while syncing
            tooltip: 'Sync Now',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Text(
                _syncStatus,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: _tasksBox.listenable(), // Listen for changes in the Hive box
        builder: (context, box, _) {
          // Filter out soft-deleted tasks for display and sort by last modified
          final tasks = box.values.where((task) => !task.isDeleted).toList()
            ..sort((a, b) => b.lastModified.compareTo(a.lastModified)); // Newest first

          if (tasks.isEmpty && !_isSyncing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No tasks found. Add a new task or sync!'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _syncData,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                elevation: 2,
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) => _toggleTaskCompletion(task),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isDirty ? Theme.of(context).colorScheme.primary : null, // Highlight dirty tasks
                      fontStyle: task.isDirty ? FontStyle.italic : null,
                    ),
                  ),
                  subtitle: Text(
                    '${task.isDirty ? 'Unsynced change • ' : ''}Last modified: ${task.lastModified.toLocal().toString().substring(0, 16)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteTask(task),
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onTap: () => _showEditTaskDialog(task), // Tap to edit task
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Dialogs for Add/Edit Tasks ---

  // Shows a dialog to add a new task.
  void _showAddTaskDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter task title'),
            autofocus: true,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _addTask(value);
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addTask(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Shows a dialog to edit an existing task's title.
  void _showEditTaskDialog(Task task) {
    final TextEditingController controller = TextEditingController(text: task.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new task title'),
            autofocus: true,
            onSubmitted: (value) async {
              if (value.isNotEmpty && value != task.title) {
                final updatedTask = task.copyWith(
                  title: value,
                  lastModified: DateTime.now(),
                  isDirty: true,
                );
                await _tasksBox.put(updatedTask.id, updatedTask);
                setState(() {});
                _syncData();
              }
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.isNotEmpty && controller.text != task.title) {
                  final updatedTask = task.copyWith(
                    title: controller.text,
                    lastModified: DateTime.now(),
                    isDirty: true,
                  );
                  await _tasksBox.put(updatedTask.id, updatedTask);
                  setState(() {});
                  _syncData(); // Trigger sync after local change
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
