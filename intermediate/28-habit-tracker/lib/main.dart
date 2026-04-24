import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs.
import 'package:table_calendar/table_calendar.dart'; // For the calendar view.

// =============================================================================
// IMPORTANT: Add the following to your pubspec.yaml under dependencies:
//
//   shared_preferences: ^2.2.0
//   uuid: ^4.1.0
//   table_calendar: ^3.0.9
//
// Then run 'flutter pub get'.
// =============================================================================

void main() {
  runApp(const MyApp());
}

// -----------------------------------------------------------------------------
// 1. Habit Model
//    Defines the structure of a habit, including serialization for storage.
// -----------------------------------------------------------------------------
class Habit {
  final String id;
  String name;
  final DateTime creationDate;
  Set<String> completedDates; // Stored as ISO 8601 date strings (YYYY-MM-DD)

  Habit({
    required this.id,
    required this.name,
    required this.creationDate,
    Set<String>? completedDates,
  }) : completedDates = completedDates ?? {};

  // Factory constructor to create a Habit object from a JSON map.
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
      completedDates: Set<String>.from(json['completedDates'] as List<dynamic>),
    );
  }

  // Converts the Habit object to a JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creationDate': creationDate.toIso8601String(),
      'completedDates': completedDates.toList(), // Convert Set to List for JSON
    };
  }

  // Helper to check if the habit was completed on a specific day.
  bool isCompletedOn(DateTime date) {
    return completedDates.contains(date.toIso8601DateString());
  }

  // Helper to toggle completion status for a specific day.
  void toggleCompletion(DateTime date) {
    final dateString = date.toIso8601DateString();
    if (completedDates.contains(dateString)) {
      completedDates.remove(dateString);
    } else {
      completedDates.add(dateString);
    }
  }
}

// -----------------------------------------------------------------------------
// 2. Data Store (SharedPreferences)
//    Manages loading, saving, and updating habits using SharedPreferences.
//    Uses ValueNotifier to notify UI about changes.
// -----------------------------------------------------------------------------
class HabitDataStore {
  static const String _habitsKey = 'habits';
  late SharedPreferences _prefs;
  final ValueNotifier<List<Habit>> _habits = ValueNotifier<List<Habit>>([]);

  // Getter for the ValueNotifier to allow UI widgets to listen for changes.
  ValueNotifier<List<Habit>> get habitsNotifier => _habits;

  // Initializes SharedPreferences and loads existing habits.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadHabits();
  }

  // Loads habits from SharedPreferences. If none, provides sample data.
  void _loadHabits() {
    final String? habitsJson = _prefs.getString(_habitsKey);
    if (habitsJson != null) {
      final List<dynamic> habitJsonList = json.decode(habitsJson);
      _habits.value = habitJsonList.map((e) => Habit.fromJson(json.decode(e as String) as Map<String, dynamic>)).toList();
    } else {
      // Provide some reasonable default/sample data if no habits are found.
      _habits.value = [
        Habit(
          id: const Uuid().v4(),
          name: 'Drink 8 glasses of water',
          creationDate: DateTime(2023, 10, 1),
          completedDates: {
            DateTime(2023, 10, 2).toIso8601DateString(),
            DateTime(2023, 10, 3).toIso8601DateString(),
            DateTime(2023, 10, 4).toIso8601DateString(),
            DateTime(2023, 10, 5).toIso8601DateString(),
            DateTime(2023, 10, 6).toIso8601DateString(),
            DateTime(2023, 10, 9).toIso8601DateString(),
            DateTime(2023, 10, 10).toIso8601DateString(),
            DateTime.now().subtract(const Duration(days: 2)).toIso8601DateString(),
            DateTime.now().subtract(const Duration(days: 1)).toIso8601DateString(),
            DateTime.now().toIso8601DateString(),
          },
        ),
        Habit(
          id: const Uuid().v4(),
          name: 'Read 30 minutes',
          creationDate: DateTime(2023, 10, 5),
          completedDates: {
            DateTime(2023, 10, 5).toIso8601DateString(),
            DateTime(2023, 10, 6).toIso8601DateString(),
            DateTime(2023, 10, 7).toIso8601DateString(),
            DateTime.now().toIso8601DateString(),
          },
        ),
      ];
      _saveHabits(); // Save sample data for initial load.
    }
  }

  // Saves the current list of habits to SharedPreferences.
  // Habits are first converted to JSON strings, then the list of strings is JSON-encoded.
  Future<void> _saveHabits() async {
    final List<String> habitJsonStrings = _habits.value.map((habit) => json.encode(habit.toJson())).toList();
    await _prefs.setString(_habitsKey, json.encode(habitJsonStrings));
  }

  // Adds a new habit and triggers a UI update.
  void addHabit(Habit habit) {
    _habits.value = [..._habits.value, habit]; // Create a new list to trigger ValueNotifier update.
    _saveHabits();
  }

  // Updates an existing habit and triggers a UI update.
  void updateHabit(Habit updatedHabit) {
    _habits.value = _habits.value.map((habit) {
      return habit.id == updatedHabit.id ? updatedHabit : habit;
    }).toList();
    _saveHabits();
  }

  // Deletes a habit and triggers a UI update.
  void deleteHabit(String id) {
    _habits.value = _habits.value.where((habit) => habit.id != id).toList();
    _saveHabits();
  }

  // Toggles the completion status of a habit for a specific date and triggers a UI update.
  void toggleHabitCompletion(String habitId, DateTime date) {
    final List<Habit> updatedList = _habits.value.map((habit) {
      if (habit.id == habitId) {
        habit.toggleCompletion(date);
      }
      return habit;
    }).toList();
    _habits.value = updatedList;
    _saveHabits();
  }
}

// -----------------------------------------------------------------------------
// 3. Main Application Setup
//    Configures the root MaterialApp with Material 3 theme.
// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal, // A seed color for Material 3 ColorScheme.
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const HabitTrackerHomePage(),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. Main Home Page
//    Displays a list of habits and allows adding new ones.
// -----------------------------------------------------------------------------
class HabitTrackerHomePage extends StatefulWidget {
  const HabitTrackerHomePage({super.key});

  @override
  State<HabitTrackerHomePage> createState() => _HabitTrackerHomePageState();
}

class _HabitTrackerHomePageState extends State<HabitTrackerHomePage> {
  final HabitDataStore _habitDataStore = HabitDataStore();
  final TextEditingController _habitNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _habitDataStore.init(); // Initialize the data store when the widget is created.
  }

  @override
  void dispose() {
    _habitNameController.dispose();
    _habitDataStore.habitsNotifier.dispose(); // Dispose the ValueNotifier to prevent memory leaks.
    super.dispose();
  }

  // Shows a dialog to add a new habit.
  Future<void> _addHabitDialog() async {
    _habitNameController.clear(); // Clear previous input.
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Habit'),
          content: TextField(
            controller: _habitNameController,
            decoration: const InputDecoration(
              hintText: 'Enter habit name',
              border: OutlineInputBorder(),
            ),
            autofocus: true, // Automatically focus the text field.
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: const Text('Add'),
              onPressed: () {
                if (_habitNameController.text.trim().isNotEmpty) {
                  final newHabit = Habit(
                    id: const Uuid().v4(), // Generate a unique ID for the new habit.
                    name: _habitNameController.text.trim(),
                    creationDate: DateTime.now(),
                  );
                  _habitDataStore.addHabit(newHabit);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
      ),
      body: ValueListenableBuilder<List<Habit>>(
        valueListenable: _habitDataStore.habitsNotifier, // Listen for changes in the habits list.
        builder: (context, habits, child) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                  const SizedBox(height: 16),
                  Text(
                    'No habits yet! Add your first habit.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return HabitCard(
                habit: habit,
                onTap: () {
                  // Navigate to the detail screen when a habit card is tapped.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitDetailScreen(
                        habit: habit,
                        habitDataStore: _habitDataStore,
                      ),
                    ),
                  );
                },
                onDelete: () async {
                  // Show a confirmation dialog before deleting a habit.
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Habit'),
                        content: Text('Are you sure you want to delete "${habit.name}"?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                            child: const Text('Delete'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    _habitDataStore.deleteHabit(habit.id);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addHabitDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. Habit Card Widget
//    A stateless widget to display a single habit in the list.
// -----------------------------------------------------------------------------
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0), // Match card border radius for ink splash.
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  habit.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                onPressed: onDelete,
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 6. Habit Detail Screen (Calendar View)
//    Displays a calendar to track habit completion for each day.
// -----------------------------------------------------------------------------
class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  final HabitDataStore habitDataStore;

  const HabitDetailScreen({
    super.key,
    required this.habit,
    required this.habitDataStore,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay; // Represents the day currently selected by the user in the calendar.

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Initially select today when the screen loads.
  }

  // Returns a list of 'events' for a given day. Here, an 'event' is just a placeholder
  // to indicate if the habit was completed on that day.
  List<dynamic> _getEventsForDay(DateTime day) {
    // The TableCalendar eventLoader expects a List. We return a non-empty list
    // if the habit was completed to show a marker.
    return widget.habit.isCompletedOn(day) ? ['Completed'] : [];
  }

  // Callback when a day is selected on the calendar.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Only update UI if the selected day is not in the future.
    if (selectedDay.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot mark habits for future dates.'),
          duration: Duration(seconds: 2),
        ),
      );
