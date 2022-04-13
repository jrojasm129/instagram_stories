import 'package:flutter/material.dart';
import 'package:instagram_histories/data/data.dart';
import 'package:instagram_histories/screens/story_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: StoryScreen(stories: stories)
    );
  }
}