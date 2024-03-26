// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_app_for_esp32_03/connect_page.dart';
import 'package:flutter_app_for_esp32_03/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectPage = 0;
  final _pageOptions = [
    HomePage(),
    ConnectPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: AppBar(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectPage,
          onTap: (int index) {
            setState(() {
              _selectPage = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cast_connected),
              label: "Connect",
            )
          ],
        ),
        body: _pageOptions[_selectPage],
      ),
    );
  }
}
