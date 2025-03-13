import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;

class Todo {
  List<String> args;
  List<String> task = [];
  List<String> completedTask = [];

  Todo({this.args = const []});

  void addTask(int index) {
    this.task.add(this.args[index]);
    writeToCsv();
  }

  void removeTask(int index) {
    this.task.remove(this.args[index]);
    writeToCsv();
  }

  void updateTask(int index, int updateIndex) {
    if (task.indexOf(this.args[index]) == -1) {
      print("Task not found");
      return;
    }
    this.task[task.indexOf(this.args[index])] = this.args[updateIndex];
    writeToCsv();
  }

  void completeTask(int index) {
    if (task.indexOf(this.args[index]) == -1) {
      print("Task not found");
      return;
    }
    this.task.remove(this.args[index]);
    this.completedTask.add(this.args[index]);
    writeToCsv();
  }

  void searchTask(int index) {
    if (task.indexOf(this.args[index]) == -1) {
      print("Task not found");
      return;
    }
    print("Task found: ${this.args[index]}");
  }

  void displayTasks() {
    for (String t in task) {
      print("Pending tasks are : $t");
    }
    for (String ct in completedTask) {
      print("Completed tasks are : $ct");
    }
  }

  void writeToCsv() async {
    final filePath = path.join(Directory.current.path, 'tasks.csv');
    List<List<dynamic>> csvData = [
      ['Task', 'Status']
    ];
    for (String t in task) {
      csvData.add([t, 'Pending']);
    }
    for (String ct in completedTask) {
      csvData.add([ct, 'Completed']);
    }
    String csv = const ListToCsvConverter().convert(csvData);
    final file = File(filePath);
    await file.writeAsString(csv);
  }

  Future<void> readFromCsv() async {
    final filePath = path.join(Directory.current.path, 'tasks.csv');
    final file = File(filePath);
    if (await file.exists()) {
      final csvData = await file.readAsString();
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
      for (var row in rows) {
        if (row[1] == 'Pending') {
          task.add(row[0]);
        } else if (row[1] == 'Completed') {
          completedTask.add(row[0]);
        }
      }
    }
  }
}

void main(List<String> args) async {
  if (args.isEmpty) {
    print("No arguments provided");
    return;
  }
  Todo t = Todo(args: args);
  await t.readFromCsv();
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case "add":
        t.addTask(i + 1);
        break;
      case "remove":
        t.removeTask(i + 1);
        break;
      case "update":
        t.updateTask(i + 1, i + 2);
        break;
      case "display":
        t.displayTasks();
        break;
      case "complete":
        t.completeTask(i + 1);
        break;
      case "help":
        print(
          "The existing commands are add, remove, update, display, and complete\nPlease use the above commands only",
        );
        break;
      case "search":
        t.searchTask(i + 1);
        break;
      default:
        break;
    }
  }
}
