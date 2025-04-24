import 'package:flutter/material.dart';
import 'Todo.dart';

class DetailScreen extends StatelessWidget {
  final Todo todo;

  // Nhận dữ liệu từ màn hình trước qua constructor
  const DetailScreen({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(todo.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(todo.description),
      ),
    );
  }
}
