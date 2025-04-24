import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Go back!'),
          onPressed: () {
            // Quay trở lại màn hình trước
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
