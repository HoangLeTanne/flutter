import 'package:flutter/material.dart';
import 'Todo.dart';           // model Todo chứa title & description
import 'package:app_04/DetailScreen.dart';  // màn hình chi tiết Todo

void main() {
  runApp(MyApp());
}

// Widget gốc
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Navigation Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoScreen(), // màn hình hiển thị danh sách Todo
    );
  }
}

// Màn hình hiển thị danh sách Todo
class TodoScreen extends StatelessWidget {
  // Tạo danh sách mẫu
  final List<Todo> todos = List.generate(
    20,
        (index) => Todo(
      'Todo $index',
      'A description of what needs to be done for Todo $index',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(todos[index].title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(todo: todos[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
