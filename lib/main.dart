import 'package:daily_drop/pages/home_page.dart';
import 'package:daily_drop/pages/login_page.dart';
import 'package:daily_drop/pages/profile_page.dart';
import 'package:daily_drop/pages/trending_page.dart';
import 'package:daily_drop/widget_tree.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: WidgetTree(),
    );
  }
}
