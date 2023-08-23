import 'package:flutter/material.dart';
import 'package:snake_game/board_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      theme: ThemeData(brightness: Brightness.dark),
      home: const BoardView(),
    );
  }
}
