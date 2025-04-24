import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hiển thị hình ảnh'),

        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // chia đều khoảng cách
            children: [
              Expanded(
                child: Image.asset('assets/images/1.png'),
              ),
              Expanded(
                child: Image.asset('assets/images/2.png'),
              ),
              Expanded(
                child: Image.asset('assets/images/3.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
