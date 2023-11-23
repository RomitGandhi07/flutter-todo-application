import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(
    'kCIAO9W4z7DGfzH0S81KWWEv0RaXNlIUQoOY3CrE',
    'https://parseapi.back4app.com',
    clientKey: 'M7xFLbCb7fFRtMusgR9xt5vjP3nFWJY7O9xhb4TM',
    autoSendSessionId: true,
    debug: true,
  );

  runApp(MyApp());
}

class Task {
  late String title;
  late String description;

  Task({required this.title, required this.description});

  TaskDetails toTaskDetails() {
    return TaskDetails(title: title, description: description);
  }
}

class TaskDetails {
  String title;
  String description;

  TaskDetails({required this.title, required this.description});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Back4App Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: TodoList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late List<ParseObject> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  _loadTasks() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('Task'))
          ..orderByDescending('createdAt');
    var apiResponse = await queryBuilder.query();
    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        tasks = List<ParseObject>.from(apiResponse.results!);
      });
    }
  }

  _addTask(String title, String description) async {
    ParseObject newTask = ParseObject('Task')
      ..set<String>('title', title)
      ..set<String>('description', description);

    var apiResponse = await newTask.save();
    if (apiResponse.success) {
      _loadTasks();
      _showSnackBar("Task Added Successfully");
    } else {
      _showErrorDialog(apiResponse.error!.message, context);
    }
  }

  _updateTask(ParseObject task, String title, String description) async {
    task.set<String>('title', title);
    task.set<String>('description', description);

    var apiResponse = await task.save();
    if (apiResponse.success) {
      // Reload tasks after updating a task
      _loadTasks();
      _showSnackBar("Task Updated Successfully");
    } else {
      _showErrorDialog(apiResponse.error!.message, context);
    }
  }

  _deleteTask(ParseObject task) async {
    var apiResponse = await task.delete();
    if (apiResponse.success) {
      _loadTasks();
      _showSnackBar("Task Deleted Successfully");
    } else {
      _showErrorDialog(apiResponse.error!.message, context);
    }
  }

  _showErrorDialog(String errorMessage, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  _showAddTaskDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Task'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)))),
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)))),
            onPressed: () async {
              await _addTask(titleController.text, descriptionController.text);
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditTaskDialog(ParseObject task) async {
    TextEditingController titleController =
        TextEditingController(text: task.get('title'));
    TextEditingController descriptionController =
        TextEditingController(text: task.get('description'));

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)))),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)))),
            onPressed: () {
              _updateTask(
                  task, titleController.text, descriptionController.text);
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteTaskDialog(ParseObject task) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to delete the task below?'),
            SizedBox(height: 8.0),
            Text(
              task.get('title'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)))),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteTask(task);
              Navigator.pop(context); // Close the dialog
            },
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)))),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  _showTaskDetailsDialog(Task task) {
    TaskDetails taskDetails = task.toTaskDetails();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Task Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${taskDetails.title}'),
            Text('Description: ${taskDetails.description}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.red)))),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          ParseObject task = tasks[index];
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(task.get('title')),
              subtitle: Text(task.get('description')),
              onTap: () {
                _showTaskDetailsDialog(Task(
                    title: task.get('title'),
                    description: task.get('description')));
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showEditTaskDialog(task);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteTaskDialog(task);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
        elevation: 2.0,
      ),
    );
  }
}
