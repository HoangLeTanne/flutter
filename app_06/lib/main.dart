import 'package:app_06/Task_Manager/views/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:app_06/Task_Manager/views/LoginScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Đặt LoginScreen làm màn hình chính
    );
  }
}