import 'package:flutter/material.dart';
import 'package:app_04/SecondScreen.dart';

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: ElevatedButton( // Flutter khuyến khích dùng ElevatedButton thay vì RaisedButton
          child: Text('Launch screen'),
          onPressed: () {
            // Khi nhấn nút thì điều hướng sang màn hình thứ 2
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondScreen()),
            );
          },
        ),
      ),
    );
  }
}
