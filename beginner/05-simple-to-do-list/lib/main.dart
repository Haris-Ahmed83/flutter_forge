import 'package:flutter/material.dart';

/// The main entry point of the application.
void main() => runApp(const MyApp());

/// The root widget of the application, setting up the Material Design theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple To-Do List',
      // Define the application theme, enabling Material 3.
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue, // A primary color for the app.
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}

/// A simple data model for a single to-do item.
class TodoItem {
  String title;
  bool isCompleted;

  TodoItem({required this.title, this.isCompleted = false});
}

/// A StatefulWidget that manages the list of to-do items and their states.
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

/// The state class for TodoListScreen, holding the list of TodoItems.
class _TodoListScreenState extends State<TodoListScreen> {
  // The list of to-do items, initialized as an empty list.
  final List<TodoItem> _todoItems = [];

  // Controller for the text input field in the add new to-do dialog.
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addSampleData(); // Populate with some initial data when the widget is created.
  }

  @override
  void dispose() {
    _textFieldController.dispose(); // Clean up the controller when the widget is removed.
    super.dispose();
  }

  /// Adds some default to-do items to the list.
  void _addSampleData() {
    // setState is called to trigger a UI rebuild after adding items.
    setState(() {
      _todoItems.add(TodoItem(title: 'Learn Flutter Basics', isCompleted: true));
      _todoItems.add(TodoItem(title: 'Build a Simple To-Do App'));
      _todoItems.add(TodoItem(title: 'Explore Material 3 Design'));
      _todoItems.add(TodoItem(title: 'Walk the dog'));
      _todoItems.add(TodoItem(title: 'Buy groceries'));
    });
  }

  /// Adds a new to-do item to the list.
  void _addTodoItem(String title) {
    // Only add if the title is not empty.
    if (title.trim().isNotEmpty) {
      // setState is called to update the UI with the new item.
      setState(() {
        _todoItems.add(TodoItem(title: title.trim()));
      });
    }
  }

  /// Toggles the completion status of a to-do item at a given index.
  void _toggleTodoStatus(int index) {
    // setState is called to reflect the change in completion status on the UI.
    setState(() {
      _todoItems[index].isCompleted = !_todoItems[index].isCompleted;
    });
  }

  /// Deletes a to-do item at a given index from the list.
  void _deleteTodoItem(int index) {
    // setState is called to remove the item from the UI.
    setState(() {
      _todoItems.removeAt(index);
    });
  }

  /// Displays an AlertDialog to allow the user to add a new to-do item.
  Future<void> _showAddTodoDialog() async {
    _textFieldController.clear(); // Clear the text field before showing the dialog.
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New To-Do Item'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Enter your to-do item'),
            autofocus: true, // Automatically focus the text field.
            onSubmitted: (value) {
              // Allows adding the item by pressing enter on the keyboard.
              if (value.isNotEmpty) {
                _addTodoItem(value);
                Navigator.of(context).pop(); // Close the dialog.
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without adding.
              },
            ),
            // Material 3 FilledButton for the primary action.
            FilledButton(
              child: const Text('Add'),
              onPressed: () {
                if (_textFieldController.text.isNotEmpty) {
                  _addTodoItem(_textFieldController.text);
                  Navigator.of(context).pop(); // Close the dialog.
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
        title: const Text('Simple To-Do List'),
      ),
      // The body uses ListView.builder to efficiently display a scrollable list of items.
      body: _todoItems.isEmpty
          ? Center(
              child: Text(
                'No to-do items yet! Add one using the + button.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _todoItems.length,
              itemBuilder: (context, index) {
                final item = _todoItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Card(
                    // Use Card for better visual separation and elevation.
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      leading: Checkbox(
                        value: item.isCompleted,
                        onChanged: (bool? newValue) {
                          // Toggles completion status when the checkbox is tapped.
                          _toggleTodoStatus(index);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          // Apply line-through and grey color if the item is completed.
                          decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                          color: item.isCompleted ? Colors.grey : null,
                          fontWeight: item.isCompleted ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Theme.of(context).colorScheme.error, // Use error color for delete.
                        onPressed: () {
                          // Deletes the item when the delete icon is pressed.
                          _deleteTodoItem(index);
                        },
                      ),
                      onTap: () {
                        // Toggles completion status when the list tile itself is tapped.
                        _toggleTodoStatus(index);
                      },
                    ),
                  ),
                );
              },
            ),
      // FloatingActionButton to add new to-do items.
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog, // Calls the dialog function on press.
        child: const Icon(Icons.add),
      ),
    );
  }
}
