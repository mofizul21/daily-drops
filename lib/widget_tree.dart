import 'package:daily_drop/includes/constants.dart';
import 'package:daily_drop/pages/Home_Page.dart';
import 'package:daily_drop/pages/Login_Page.dart';
import 'package:daily_drop/pages/Profile_Page.dart';
import 'package:daily_drop/pages/Trending_Page.dart';
import 'package:flutter/material.dart';
import 'package:daily_drop/widgets/bottom_navigation.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  List<Widget> pageList = [
    LoginPage(),
    HomePage(),
    TrendingPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appname)),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, value, child) {
          return pageList[value];
        },
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
